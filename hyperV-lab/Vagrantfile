# -*- mode: ruby -*-
# vi: set ft=ruby :


#vagrant

## HOST PRE-REQUISITES
# vagrant
# hyper-v enabled
# vagrant plugins: vagrant-env
# $vagrant plugin install vagrant-env

#bash
# VAGRANT_VAGRANTFILE=Vagrantfile-k8s-containerd vagrant status
#powershell
# [Environment]::SetEnvironmentVariable("VAGRANT_VAGRANTFILE", "Vagrantfile-k8s-containerd", "Session")
# [Environment]::GetEnvironmentVariable('VAGRANT_VAGRANTFILE', 'Session')
# vagrant status

#Array of Hashes
controlPlaneNodes=[
  {
	:hostname => "c1-cp1",
    :ip => "172.16.94.10",
    :box => "bento-ubuntu-18.04",
    :ram => 2048,
    :cpu => 2
  }
  # ,
  # {
    # :hostname => "c1-node1",
    # #:ip => "192.168.100.11",
    # :box => "bento-ubuntu-18.04",
    # :ram => 2048,
    # :cpu => 2
  # }
]

dataPlaneNodes=[
  {
	:hostname => "c1-node1",
    :ip => "172.16.94.20",
    :box => "bento-ubuntu-18.04",
    :ram => 2048,
    :cpu => 2
  }
]


$VM_TOOLS = <<-TOOLS
  ## Install yq
  sudo snap install yq
TOOLS


Vagrant.configure(2) do |config|
	## TRIGGERS BEGIN
	config.trigger.before :up do |trigger|
		trigger.info = "[TRIGGER] - Start VM"
		trigger.run = {inline: 'date >> vm-start.log'}
	end 

	config.trigger.before :halt do |trigger|
		trigger.info = "[TRIGGER] - Stop VM"
		trigger.run = {inline: 'date >> vm-stop.log'}
	end 
	## TRIGGERS END

  #Control Plane
  controlPlaneNodes.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.provider :hyperv do |hyperv|
        hyperv.memory = machine[:ram]
        hyperv.cpus = machine[:cpu]
        hyperv.vmname = machine[:hostname]
      end	#hyperv		
      node.vm.guest = :linux
      node.vm.hostname = machine[:hostname]
      node.vm.network "public_network", ip: machine[:ip]
      
      k8s_node_name = machine[:hostname]
      k8s_api_server_ip = machine[:ip]
      $post_up_message = <<-MSG
      ------------------------------------------------------
      ================  CONTROL PLANE NODE  ================
      k8s_node: #{k8s_node_name}
      Cluster IP: #{k8s_api_server_ip}
  
      ------------------------------------------------------
      MSG
      node.vm.post_up_message = $post_up_message

      ## k8s BEGIN 
      node.vm.provision "shell", inline: $VM_TOOLS
      node.vm.provision "shell", inline: "/vagrant/scripts/common-node-bootstrap-containerd.sh"
      node.vm.provision "shell", inline: "/vagrant/scripts/control-plane-node-bootstrap.sh"
      ## k8s END
    end #node
    config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: ".git/",
    rsync__args: ["--verbose", "--rsync-path='sudo rsync'", "--archive", "--delete", "-z"]
  
  end #machine Control Plane

  #Data Plane
  dataPlaneNodes.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.provider :hyperv do |hyperv|
        hyperv.memory = machine[:ram]
        hyperv.cpus = machine[:cpu]
        hyperv.vmname = machine[:hostname]
      end	#hyperv		
      node.vm.guest = :linux
      node.vm.hostname = machine[:hostname]
      node.vm.network "public_network", ip: machine[:ip]
      
      k8s_node_name = machine[:hostname]
      k8s_api_server_ip = machine[:ip]
      $post_up_message = <<-MSG
      ------------------------------------------------------
      ================  CONTROL PLANE NODE  ================
      k8s_node: #{k8s_node_name}
      Cluster IP: #{k8s_api_server_ip}
 
      ------------------------------------------------------
      MSG
      node.vm.post_up_message = $post_up_message

      ## k8s BEGIN 
      node.vm.provision "shell", inline: $VM_TOOLS
      node.vm.provision "shell", inline: "/vagrant/scripts/common-node-bootstrap-containerd.sh"
      node.vm.provision "shell", inline: "/vagrant/scripts/data-plane-node-bootstrap.sh"
      ## k8s END
    end #node
    config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: ".git/",
    rsync__args: ["--verbose", "--rsync-path='sudo rsync'", "--archive", "--delete", "-z"]  
  end #machine Data Plane
end #config

