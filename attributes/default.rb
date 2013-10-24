default[:go][:backup_path] = ""

default[:go][:agent][:server_host]           = '127.0.0.1'
default[:go][:agent][:auto_register]         = false
default[:go][:agent][:auto_register_key]     = 'default_auto_registration_key'
# Install this many agent instances on a box - default is one per CPU
default[:go][:agent][:instance_count] = node[:cpu][:total]

default[:go][:version]                       = '13.2.0-17155'

default[:go][:install_method]                = 'package' #alternative is 'file'

# These values are used when file is specified as the install_method
default['go']['server']['package_name']         = "go-server-#{go[:version]}.noarch.rpm"
default['go']['server']['package_url']          = "http://download01.thoughtworks.com/go/yum/no-arch/#{go[:server][:package_name]}"

default['go']['agent']['package_name']          = "go-agent-#{go[:version]}.noarch.rpm"
default['go']['agent']['package_url']           = "http://download01.thoughtworks.com/go/yum/no-arch/#{go[:agent][:package_name]}"

default[:go][:omit_repos] = false
default[:go][:omit_java] = false