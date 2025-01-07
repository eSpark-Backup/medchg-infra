# update pv worker ip 
# copy services folder for kubernates to bastian 
cd /mnt/d/Projects/espark/knozi/k8s
scp -r services ubuntu@50.16.82.119:./ #bastian
scp ~/.ssh/id_rsa ubuntu@50.16.82.119:~/.ssh/ #bastian

ssh -i ~/.ssh/id_rsa ubuntu@50.16.82.119 #bastian
sudo chmod 400 ~/.ssh/id_rsa



# copy services folder for kubernates to bastian 
scp -r services ubuntu@10.0.20.221:./ #master 

ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.221 #master 

ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.227 #worker1
# for local volumes on each worker
sudo mkdir /opt/volume
sudo mkdir /opt/volume/kubernates

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

		
# install CNI flanel
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
# Install calico better performance 
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml


# install helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# ALias user specific
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

# join workers commands
kubeadm token create --print-join-command # master
sudo kubeadm join 10.0.20.221:6443 --token 83ky3x.ehj3r7w85qq1e7q4 \
        --discovery-token-ca-cert-hash sha256:12f737935485b6c316c406258b6e7b9db96e9dcc6f0f045e1ebcef320e30cf50


# for services 
cd
cd services/nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx --values values.yaml ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace 


cd
cd services/storageclass
kubectl apply -f standard.yaml
kubectl apply -f pv.yaml

cd 
cd services/cnpg
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml

wait .....  
  
kubectl create namespace dev-cnpg  
kubectl apply -f deploy.yaml

kubectl create secret generic aws-s3-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=AKIA4GX3SSVUCURASQD2 \
  --from-literal=AWS_SECRET_ACCESS_KEY=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 -n dev-cnpg


cd 
cd services/argocd
kubectl create namespace argocd
kubectl apply -n argocd -f deploy.yaml

wait  .... 

kubectl apply -f ingress.yaml

wait.... 

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d



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
		- [x] CNI Calico
		- [x] Storage Class
			- [x] no provision 
			- [x] local-pv
		- [x] NGINX Ingress
		- [x] Test Deploy (for testing)
		- [x] Cert Manager
			- [x] Tested Lets Encrypt 
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