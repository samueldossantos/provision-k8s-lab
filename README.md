# provision-k8s-lab

# (unintentional) k8s deployment troubleshoot lab (thanks Hyper-V)

$Vagrantfile$ deploys a Kubernetes cluster, using $containerd$ container runtime using Hyper-V as the hypervisor.

Aim was to deploy a fully functional, fully automated K8s cluster, with a configurable number of control plane and work nodes.

Currently implementation does not achieve the initial goal, due to the Issues identified however, fully functional cluster can be achieve using a semi-automated process.

Also, deploying k8s cluster as is, provides an interesting way to troubleshoot a k8s cluster so, not all is lost and, can offer a

# Challenges/Issues

## Issue1 - IP address varies and can't be set
The objective to have a fully automated K8s deployment fails since I can't define the IP address for the control plane.

Hyper-V manages the IP addresses in it's own way and it's not possible to control IP address assignment.
https://www.vagrantup.com/docs/providers/hyperv/limitations

Also, this article describes the limitations I've found by using Vagrant and Hyper-V:
https://technology.amis.nl/tech/vagrant-and-hyper-v-dont-do-it/

## Issue2 - rsync not bidirectional
I'm relying, on the shared folder, to transfer the join command, to allow the work node to join the cluster. Without this the automatic cluster provisioned is voided.

Also, using SMB isn't an option since it requires some manual interation during vagrant up.