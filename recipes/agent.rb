include_recipe 'java'

go_server               = node[:go][:agent][:server_host]
package_url             = node[:go][:agent][:package_url]
package_checksum        = node[:go][:agent][:package_checksum]
go_server_autoregister  = node[:go][:agent][:auto_register]
autoregister_key        = node[:go][:agent][:auto_register_key]

include_recipe 'go::repos' unless node[:go][:ommit_repos]

package "go-agent" do
  version node[:go][:version]
  options "--force-yes" if platform_family?("debian")
  notifies :start, 'service[go-agent]', :immediately
end
  
if Chef::Config[:solo] || node.attribute.go?(:server)
  Chef::Log.warn("Chef-solo invocation detected.  node[:go][:server] attribute will be used for server instance configuration.")
  Chef::Log.info("Using #{node[:go][:server][:host]} for server instance configuration, as specified in node[:go][:server][:host].")
else
  go_servers = search(:node, "chef_environment:#{node.chef_environment} AND recipes:go-server")
  go_server = "#{go_servers[0][:ipaddress]}"
  go_server_autoregister = "#{go_servers[0][:go][:auto_register_agents]}"
  Chef::Log.info("Found Go server at ip address #{go_server} with automatic agent registration=#{go_server_autoregister}")
  if (go_server_autoregister)
    Chef::Log.warn("Agent auto-registration enabled.  This agent will not require approval to become active.")
    autoregister_key = "#{go_servers[0][:go][:autoregister_key]}"
  else
    autoregister_key = ""
  end
end

# Install & configure the initial (default) Go agent as it comes from the binary distribution
# Then install any additional agents with -COUNT addition.
# i.e.
# /etc/default/go-agent
#             /go-agent-2
#             /go-agent-3
# /var/lib/go-agent
#         /go-agent-2
#         /go-agent-3
#
# default[:go][:agent][:instance_count] = node[:cpu][:total]

(1..node[:go][:agent][:instance_count]).each do |i|
  log "Configuring Go agent # #{i} of #{node[:go][:agent][:instance_count]} for Go server at #{go_server}:8153 "
  if (i < 2)
    suffix = ""
  else
    suffix = "-#{i}"
  end
  
  template "/etc/init.d/go-agent#{suffix}" do
    # <%= @go_agent_instance -%>
    source 'go-agent-service.erb'
    mode '0755'
    owner 'root'
    group 'root'
    variables(:go_agent_instance => suffix)
    subscribes :create, "package[go-agent]"
    notifies :enable, "service[go-agent#{suffix}]", :delayed
    action :nothing
  end

  template "/etc/default/go-agent#{suffix}" do
    source 'go-agent-defaults.erb'
    mode '0644'
    owner 'go'
    group 'go'
    variables(:go_server_host => go_server, 
      :go_server_port => '8153', 
      :go_agent_instance => suffix,
      # TODO - Fix Java Home
      :java_home => "/usr/lib/jvm/default-java",
      :work_dir => "/var/lib/go-agent#{suffix}")
    subscribes :create, "template[/etc/init.d/go-agent#{suffix}]"
    action :nothing
  end
  
  template "/usr/share/go-agent/agent#{suffix}.sh" do
    source 'go-agent-sh.erb'
    mode '0755'
    owner 'go'
    group 'go'
    variables(:go_agent_instance => suffix)
    subscribes :create, "template[/etc/init.d/go-agent#{suffix}]"
    action :nothing
  end

  log "Registering agent#{suffix} with autoregister key of " + autoregister_key
  directory "/var/lib/go-agent#{suffix}" do
    mode '0755'
    owner 'go'
    group 'go'
    subscribes :create, "template[/etc/init.d/go-agent#{suffix}]"
    action :nothing
  end
  directory "/var/lib/go-agent#{suffix}/config" do
    mode '0755'
    owner 'go'
    group 'go'
    subscribes :create, "Directory[/var/lib/go-agent#{suffix}]"
    action :nothing
  end
  template "/var/lib/go-agent#{suffix}/config/autoregister.properties" do
    source 'autoregister.properties.erb'
    group 'go'
    owner 'go'
    mode 0644
    variables(:autoregister_key => autoregister_key,
            :agent_resources => "#{node[:os]}, #{node[:platform]},#{node[:platform]}-#{node[:platform_version]}")
    subscribes :create, "directory[/var/lib/go-agent#{suffix}/config]"
    action :nothing
  end
  

  service "go-agent#{suffix}" do
    supports :status => true, :restart => true, :reload => true, :start => true
    action :nothing
    subscribes :restart, "template[/etc/init.d/go-agent#{suffix}]"
    subscribes :restart, "template[/var/lib/go-agent#{suffix}/config/autoregister.properties]"
    subscribes :restart, "template[/etc/default/go-agent#{suffix}]"
  end
  
end


