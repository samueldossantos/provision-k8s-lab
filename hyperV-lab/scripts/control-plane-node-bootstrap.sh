#!/bin/bash


#Creating a Control Plane node
i=1;
for arg in "$@" 
do
    echo "Argument - $i: $arg";
    i=$((i + 1));
done

#Set Cluster API Server address (used in ClusterConfiguration.yaml file)
apiServerIpAddr=$1

#bootstrapping a cluster with kubeadm
kubeadm config print init-defaults | tee ClusterConfiguration.yaml 1> /dev/null
#sudo sed -i 's/  advertiseAddress: 1.2.3.4/  advertiseAddress: $apiServerIpAddr/g' ClusterConfiguration.yaml
# nice tip from https://zhu45.org/posts/2016/Dec/21/environment-variable-substitution-using-sed/
sudo sed -i 's|1.2.3.4|'$apiServerIpAddr'|g' ClusterConfiguration.yaml
# ToDo: use yq to handle variable
#sudo yq -i '.localAPIEndpoint.advertiseAddress = $apiServerIpAddr' ClusterConfiguration.yaml
sudo yq -i '.nodeRegistration.criSocket = "/run/containerd/containerd.sock"' ClusterConfiguration.yaml
echo -e "---"                                       | tee -a ClusterConfiguration.yaml
echo -e "apiVersion: kubelet.config.k8s.io/v1beta1" | tee -a ClusterConfiguration.yaml
echo -e "kind: KubeletConfiguration"                | tee -a ClusterConfiguration.yaml
echo -e "cgroupDriver: systemd"                     | tee -a ClusterConfiguration.yaml

#preflight checks prior to download the image
sudo kubeadm config images pull &&
sudo kubeadm init 
kubeadm token list


echo "SDS - current [\$HOME]: $HOME"
sudo -i -u vagrant bash << 'EOF'
echo "Copy kubeconfig to user home directory..."
myUser=`whoami`
echo $myUser
sudo mkdir -p /home/$myUser/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/$myUser/.kube/config
sudo chown $(id -u):$(id -g) /home/$myUser/.kube/config
sudo ls -la /home/$myUser/.kube
sudo kubectl get pods --all-namespaces
EOF


#create Pod network
wget https://docs.projectcalico.org/manifests/calico.yaml
#cat calico.yaml | grep -n  _CIDR
kubectl apply -f calico.yaml

#Create a token
#sudo touch /vagrant/scripts/join.sh 
#sudo kubeadm token create --print-join-command | sudo tee -a /vagrant/scripts/join.sh

#Get date in Z-notation UTC timestamp
nowdate=$(date --utc +%FT%TZ)
ttl=$(kubeadm token list -o json | yq e '.expires')
# if day changes then i want to reinitialize
if [ $nowdate -gt $ttl ] 
  #token expired - generate a new token 
  echo "Token expired . Something went wrong..."
else
 #List tokens (expected only one since cluster has just been bootstraped
 kubeadm token list
fi

sudo -i -u vagrant bash << EOF
#Get the CA cert hash (just for visual inspection) 
echo "CA cert hash is: "
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt |\
openssl rsa -pubin -outform der 2>/dev/null |\
openssl dgst -sha256 -hex |\
sed 's/^.* //'

echo "Token is"
kubeadm token list -o json | yq e '.token'
EOF
