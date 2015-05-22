Vagrant.configure(2) do |config|
  config.vm.box = "rhel-atomic-host"
  config.vm.define :summit_rhel_deploy_target do | host |
    host.vm.hostname = "summit-rhel-deploy-target"
    host.vm.synced_folder ".", "/vagrant", disabled: true
    host.vm.synced_folder ".", "/home/vagrant/sync", type: "rsync",
                          rsync__exclude: [ ".git/", ".#*", "*~" ]

    #ensure docker is configured correctly to be run by vagrant user
    host.vm.provision 'shell', inline: "sudo systemctl stop docker > /dev/null 2>&1 || :" #in case this isn't first run
    host.vm.provision 'shell', inline: "sudo groupadd docker > /dev/null 2>&1 || :"
    host.vm.provision 'shell', inline: "sudo usermod -a -G docker vagrant"
    host.vm.provision 'shell', inline: "sudo systemctl enable docker && sudo systemctl start docker"
    host.vm.provision 'shell', inline: "sudo chown root:docker /var/run/docker.sock"

    #setup kubernetes
	host.vm.provision 'shell', inline: "echo 'TODO: do some kubernetes setup here'"

	#pre-cache docker images
    host.vm.provision 'shell', inline: "docker pull rhel"
    host.vm.provision 'shell', inline: "docker pull centos"
    host.vm.provision 'shell', inline: "docker pull registry"

    #start docker registry
	host.vm.provision 'shell', inline: "echo 'TODO: start docker registry'"

  end
  config.vm.box = "rhel-7.1"
  config.vm.define :summit_rhel_dev do | host |
    host.vm.hostname = "summit-rhel-dev"
    host.vm.synced_folder ".", "/vagrant", disabled: true
    host.vm.synced_folder ".", "/home/vagrant/sync", type: "rsync",
                          rsync__exclude: [ ".git/", ".#*", "*~" ]

    #setup a local repo, unecessary if using this outside the lab environment
	host.vm.provision 'shell', inline: "echo 'TODO: do some stuff here, likely need RHEL-main, RHEL-Extras, RHEL-Optional?'"

    #ensure docker is configured correctly to be run by vagrant user
    host.vm.provision 'shell', inline: "sudo systemctl stop docker > /dev/null 2>&1 || :" #in case this isn't first run
    host.vm.provision 'shell', inline: "sudo groupadd docker > /dev/null 2>&1 || :"
    host.vm.provision 'shell', inline: "sudo usermod -a -G docker vagrant"
    host.vm.provision 'shell', inline: "sudo systemctl enable docker && sudo systemctl start docker"
    host.vm.provision 'shell', inline: "sudo chown root:docker /var/run/docker.sock"

    #setup kubernetes
	host.vm.provision 'shell', inline: "echo 'TODO: do some kubernetes setup here'"

	#pre-cache docker images
    host.vm.provision 'shell', inline: "docker pull rhel"
    host.vm.provision 'shell', inline: "docker pull centos"
    host.vm.provision 'shell', inline: "docker pull registry"

    #get latest lab files from remote 
	host.vm.provision 'shell', inline: "echo 'TODO: get the latest lab files'"

  end
end
