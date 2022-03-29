#!/bin/bash

#Creating a Control Plane node

#bootstrapping a cluster with kubeadm
kubeadm config print init-defaults | tee ClusterConfiguration.yaml 1> /dev/null
#sudo sed -i 's/  advertiseAddress: 1.2.3.4/  advertiseAddress: 172.16.94.10/g' ClusterConfiguration.yaml
# ToDo
yq -i '.localAPIEndpoint.advertiseAddress = "172.16.94.10"' ClusterConfiguration.yaml
yq -i '.nodeRegistration.criSocket = "/run/containerd/containerd.sock"' ClusterConfiguration.yaml
echo -e "---"                                       | tee -a ClusterConfiguration.yaml
echo -e "apiVersion: kubelet.config.k8s.io/v1beta1" | tee -a ClusterConfiguration.yaml
echo -e "kind: KubeletConfiguration"                | tee -a ClusterConfiguration.yaml
echo -e "cgroupDriver: systemd"                     | tee -a ClusterConfiguration.yaml

#preflight checks prior to download the image
sudo kubeadm config images pull
sudo kubeadm init 
sudo kubectl get pods --all-namespaces

echo "SDS - current [\$HOME]: $HOME"
sudo -i -u vagrant bash << EOF
whoami
sudo mkdir -p $HOME/.kube                   
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config
EOF

#create Pod network
wget https://docs.projectcalico.org/manifests/calico.yaml
#cat calico.yaml | grep -n  _CIDR
kubectl apply -f calico.yaml

#Get token
#Get date in Z-notation UTC timestamp
nowdate=$(date --utc +%FT%TZ)
ttl=$(kubeadm token list -o json | yq e '.expires')
# if day changes then i want to reinitialize
if [ $nowdate -lt $ttl ] 
  #token valid - list only
  echo "Token valid"
  kubeadm token list
then
  #token expired - generate a new token 
  echo "Token expired. Creating one..."
  kubeadm token create
fi

#Get the CA cert hash (just for visual inspection) 
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubkey -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

#sudo -i -u vagrant bash << EOF
sudo touch /vagrant/scripts/join.sh 
sudo kubeadm token create --print-join-command | sudo tee /vagrant/scripts/join.sh
#EOF