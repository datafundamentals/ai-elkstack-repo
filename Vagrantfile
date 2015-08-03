# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Vagrantfile for three-machine test topology. 
# ipaddresses are 10.0.1.2, 10.0.1.3, 10.0.1.4 for ai-test-1 - ai-test-3. 

VAGRANTFILE_API_VERSION = "2"

numNodes = 3

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  if Vagrant.has_plugin?("vagrant-omnibus")
		config.omnibus.chef_version = "12.0.3"
		config.omnibus.cache_packages = true
	end

	# setup numNodes
	numNodes.times do |num|
		machName = "ai-elkstack-" + String(num + 1)
		config.vm.define machName do |node_config|		
			node_config.vm.network :private_network, ip: "10.0.1.#{String(num + 2)}"
			node_config.vm.hostname = machName
		end
	end
	config.vm.provider :virtualbox do |vb|
  vb.customize ["modifyvm", :id, "--memory", "4096"]
  end
  # Setup the generic config across both servers
  config.vm.box = "opscode-ubuntu-14.04"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"

end
