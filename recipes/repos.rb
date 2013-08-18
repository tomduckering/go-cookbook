
case node['platform_family']
when "rhel","fedora"

  include_recipe 'yum'

  yum_repository "thoughtworks" do
    description 'Studios Go YUM Repository'
    url 'http://download01.thoughtworks.com/go/yum/no-arch'
    action :add
  end

when "debian"
  include_recipe 'apt'

  apt_repository "thoughtworks" do
    uri "http://download01.thoughtworks.com/go/debian"
    components ["contrib/"]
  end

end