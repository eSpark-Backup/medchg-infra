ssh -i ~/.ssh/id_rsa ubuntu@54.226.193.7 #bastian

# on bastian 
cd ~/.ssh/
nano id_rsa
sudo chmod 400 id_rsa
cd ..
ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.23 #master 
ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.104 #worker1


# master k9s ui
wget https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_linux_amd64.deb
sudo apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb


# init cluster
IPADDR=$(hostname -i)
POD_CIDR="192.168.0.0/16"
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR 


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# join
sudo kubeadm join 10.0.20.23:6443 --token 9zvzd2.cq6c1rkinnto86ko \
        --discovery-token-ca-cert-hash sha256:eedb3092595a1e3b2b9b5435e019a2a728685a6c4bbd2f3dd7bd0d99ff4a9687
		
# install CNI flanel
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
# Install calico better performance 
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml


# install helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# ALias user specific
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc


# for services 
mkdir dev
cd dev
mkdir services
cd services
mkdir nginx
cd nginx


# Error and fixes not working
## failed calling webhook "validate.nginx.ingress.kubernetes.io": failed to call webhook:
## solution 
kubectl get validatingwebhookconfigurations
kubectl delete validatingwebhookconfigurations nginx-ingress-nginx-admission


sudo tcpdump port 32080 and '(tcp-syn|tcp-ack)!=0'
curl 10.0.20.124:32080 dfwcriticalcare.medchg.com

## reset
sudo kubeadm reset
sudo rm $HOME/.kube/config
sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*

# rclone setup s3 windows mount
- for mount clmmand run wihout admin
https://medium.com/@francesco.larghi/access-amazon-s3-bucket-as-a-local-drive-on-windows-2b721100a34a
## Mount s3 to windows 
- cd C:\rclone> .\rclone.exe mount k8s-backup-231224:k8s-backup-231224/ S: --vfs-cache-mode full

# Mount s3 to ec2 
sudo apt-get update -y
sudo apt-get install awscli -y
sudo apt-get install s3fs -y
sudo mkdir /mnt/s3-bucket
cd /mnt/s3-bucket 
## just for test 
sudo touch test1.txt test2.txt 
aws s3 sync /mnt/s3-bucket s3://k8s-backup-231224
sudo s3fs k8s-backup-231224 /mnt/s3-bucket -o iam_role=k8s-s3-backup-access-role -o use_cache=/tmp -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 -o use_path_request_style -o url=https://s3-{{aws_region}}.amazonaws.com
df -h | grep s3fs

# Status

- [ ] K8s Infra
	- [x] EC2 Security 
		- [x] SSH only via bastian 
		- [x] Private Subnet
	- [ ] Services
		- [x] NGINX Ingress
		- [x] Test Deploy (for testing)
		- [x] CNPG Posgress
			- [x] Local storage PV 
			- [x] User can access db via dfwcriticalcare.medchg.com:5432
			- [x] Cloud backup on demand
			- [ ] Cloud backup periodic
		- [x] PGAdmin Web point to dfwcriticalcare.medchg.com
			- [x] SSL Fake certificate 
	- [x] Terraform
		- [x] SSH
		- [x] VPC
		- [x] Security Groups
		- [x] Subnets
		- [x] EC2
			- [x] Bastian
			- [x] Master
				- [x] UserData
					- [x] Kuebernates
						- [x] Kubectl
						- [x] KubeAdmin
						- [x] Config
					- [x] Auto Complete 
			- [x] Workers
				- [x] UserData
					- [x] Kuebernates
						- [x] Kubectl
						- [x] KubeAdmin
						- [x] Config
					- [x] Auto Complete 		
		- [x] Target Groups
			- [x] HTTP Ingress
			- [x] HTTPS Ingress
			- [x] DB30543 RW
		- [x] NLB 
		- [x] Route53