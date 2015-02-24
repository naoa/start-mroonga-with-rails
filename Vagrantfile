# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :forwarded_port, guest:3000, host:30000
  config.vm.network "private_network", ip: "192.168.33.101"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.omnibus.chef_version = '11.18.6'

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["site-cookbooks", "vendor/cookbooks"]
    chef.add_recipe "apt"
    chef.add_recipe "libssl"
    chef.add_recipe "readline"
    chef.add_recipe "git"
    chef.add_recipe 'build-essential'
    chef.add_recipe 'openssl'
    chef.add_recipe "mysql::client"
    chef.add_recipe "mysql::server"
    chef.add_recipe "mroonga"
    chef.add_recipe 'ruby_build'
    chef.add_recipe 'rbenv::system'

    chef.json = {
      "rbenv" => {
        "global" => "2.1.5",
        "rubies" => [ "2.1.5" ],
        "gems" => {
          "2.1.5" => [
            { 'name' => 'bundler' }
          ]
        }
      },
      :mysql => {
        :server_root_password => "password"
      }
    }
  end

end
