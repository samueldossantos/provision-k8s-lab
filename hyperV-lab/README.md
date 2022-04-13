# provision-k8s-lab

# (unintentional) k8s deployment troubleshoot lab (thanks Hyper-V)

$Vagrantfile$ deploys a Kubernetes cluster, using $containerd$ container runtime using Hyper-V as the hypervisor.

Aim was to deploy a fully functional, fully automated K8s cluster, with a configurable number of control plane and work nodes.

Currently implementation requires the control plane and data plane to be deployed in stages:
1. Deploy control plane nodes
```sh
VAGRANT_VAGRANTFILE=Vagrantfile-control-plane; vagrant up 2>>error.log 1>>out.log
```
Note: Use >> to append and > to create/overwrite existent file.


2. Deploye data plane nodes 
```sh
VAGRANT_VAGRANTFILE=Vagrantfile-data-plane; vagrant up 2>>error.log 1>>out.log
```
Note: Use >> to append and > to create/overwrite existent file.

## Halt a node
The following can be used to halt a VM
```sh
VAGRANT_VAGRANTFILE=<vagrant-file>; vagrant halt <node-name>
```

Example to power-off c1-cp1 node is:
```sh
VAGRANT_VAGRANTFILE=Vagrantfile-control-plane; vagrant halt c1-cp1
```

## Destroy a node
The following can be used to delete a VM:
```sh
VAGRANT_VAGRANTFILE=Vagrantfile-control-plane; vagrant destroy c1-cp1
```



Also, deploying k8s cluster as is, provides an interesting way to troubleshoot a k8s cluster so, not all is lost and, can offer a


# Challenges/Issues

## Issue1 - Node IP address can't be define by Vagrant (when provisioning with Hyper-V)
The objective to have a fully automated K8s deployment is more challenging since I can't define the IP address for the control plane. However, it can be overcoded and automation is accomplished.

Hyper-V manages the IP addresses in it's own way and it's not possible to control IP address assignment.
https://www.vagrantup.com/docs/providers/hyperv/limitations

Also, this article describes the limitations I've found by using Vagrant and Hyper-V:
https://technology.amis.nl/tech/vagrant-and-hyper-v-dont-do-it/

## Issue2 - rsync not bidirectional
I'm relying, on the shared folder, to transfer the join command, to allow the work node to join the cluster. Without this the automatic cluster provisioned is voided.

Also, using SMB isn't a desired option since it requires manual interation during vagrant up.