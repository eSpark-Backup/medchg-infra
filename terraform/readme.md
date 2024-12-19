bastian 35.153.205.203
marster 10.0.20.146
aworker1 10.0.20.67

ssh -i ~/.ssh/id_rsa ubuntu@35.153.205.203 #bastian
ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.146 #master 
ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.67 #worker1

cd ~/.ssh/
nano id_rsa
nano id_rsa.pub
sudo chmod 400 id_rsa
sudo chmod 400 id_rsa.pub
ssh -i ~/.ssh/id_rsa ubuntu@


master
wget https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_linux_amd64.deb
sudo apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb



IPADDR=$(hostname -i)
POD_CIDR="10.244.0.0/16"
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR 


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo kubeadm join 10.0.20.146:6443 --token q015g2.nflkt14lfionfl1o \
        --discovery-token-ca-cert-hash sha256:f1ced4a095473013dfdced917bc6124f214688320b9ee52ab129365a721837bb

kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml


curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


mkdir dev
cd dev
mkdir services
cd services
mkdir nginx
cd nginx



