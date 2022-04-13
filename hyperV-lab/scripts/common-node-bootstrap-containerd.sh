#!/bin/bash

#disable swap
sudo swapoff -a -v
#cat /etc/fstab

#Install a container runtime - containerd
#Load modules
sudo modprobe overlay
sudo modprobe br_netfilter

#cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
#overlay
#br_netfilter
#EOF
sudo touch /etc/modules-load.d/containerd.conf
echo "overlay"      | sudo tee -a /etc/modules-load.d/containerd.conf
echo "br_netfilter" | sudo tee -a /etc/modules-load.d/containerd.conf

#cat<<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
#net.bridge.bridge-nf-call-iptables  = 1
#net.ipv4.ip_forward                 = 1
#net.bridge.bridge-nf-call-ip6tables = 1
#EOF
echo -e "net.bridge.bridge-nf-call-iptables  = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
echo -e "net.ipv4.ip_forward                 = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
echo -e "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf		

#Apply sysctl params without reboot
sudo sysctl --system

#Install containerd
sudo apt-get update
sudo apt-get install -y containerd

#Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/g' /etc/containerd/config.toml

#Restart containerd with the new configuration
sudo systemctl restart containerd

#Install kubernets packages - kubeadm, kubelet and kubectl
#https://cloud.google.com/sdk/docs/install#deb
# --keyring option not working 
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

#Add Kubernetes apt repository
sudo apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt-get update
apt-cache policy kubelet | head -n 20

#sudo apt-get install -y kubelet kubeadm kubectl
VERSION=1.22.4-00
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt-mark hold kubelet kubeadm kubectl containerd

#1 - systemd Units
#Check the status of our kubelet and our container runtime, containerd.
#The kubelet will enter a crashloop until a cluster is created or the node is joined to an existing cluster.
sudo systemctl status kubelet.service 
sudo systemctl status containerd.service 

#Ensure both are set to start when the system starts up.
sudo systemctl enable kubelet.service
sudo systemctl enable containerd.service
