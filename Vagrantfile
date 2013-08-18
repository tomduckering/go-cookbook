# -*- mode: ruby -*-
# vi: set ft=ruby :

api_version = "2"

ubuntu_box_name = "opscode_ubuntu-12.04_chef-11.2.0"
ubuntu_box_url  = "https://opscode-vm.s3.amazonaws.com/vagrant/#{ubuntu_box_name}.box"

centos_box_name = "vagrant/opscode_centos-6.4_chef-11.4.4.box"
centos_box_name = "https://opscode-vm.s3.amazonaws.com/vagrant/#{centos_box_name}.box"

Vagrant::configure(api_version) do |config|
  config.berkshelf.enabled    = true

  config.vm.define :ubuntu do |ubuntu|

    ubuntu.vm.box               = ubuntu_box_name
    ubuntu.vm.box_url           = ubuntu_box_url

    ubuntu.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "1024"]
    end

    ubuntu.vm.network :private_network, ip: "192.168.192.2"

    ubuntu.vm.provision :chef_solo do |chef|
      chef.log_level = "info"
      chef.json = {
        "go" => {
          "server" => "127.0.0.1",
          "agent" => {
            "auto_register" => true,
            "instance_count" => 3
          }
        }
      }

      chef.run_list = [
        "recipe[go]"
      ]
    end
  end

  config.vm.define :centos do |centos|

    centos.vm.box               = centos_box_name
    centos.vm.box_url           = centos_box_url

    centos.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "1024"]
    end

    centos.vm.network :private_network, ip: "192.168.192.2"

    centos.vm.provision :chef_solo do |chef|
      chef.log_level = "info"
      chef.json = {
        "go" => {
          "server" => "127.0.0.1",
          "agent" => {
            "auto_register" => true,
            "instance_count" => 3
          }
        }
      }

      chef.run_list = [
        "recipe[go]"
      ]
    end
  end

  
end

