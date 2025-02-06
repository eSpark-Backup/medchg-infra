# Big picture
![Alt text](k8s.jpg)

# Operational commands
- https://pgadmin.medchg.com/ 
	- database web browser for dev stg prod clusters with admin access
	- username : admin@example.com
	- password : admin1234
	- to disable weburl : login to k8s master node run k9s command goto ingrees then delete pgadmin 
	
- pgadmin.medchg.com:5432
	- public connection for dev stg db server cluster
	- username : postgres
	- password : uN3i1Hh0bYbCc4TyVAacBhmSzgqtzqxmOVjAn0QIChsJrSmu9PY2fw2q8EKKLpZ9
	- maintainance database: postgres	
	- to enable/disable use terraform apply command
		- https://github.com/eSpark-Consultants/medchg_infra/blob/main/terraform/9-nlb.tf
		- find section with resouce "k8s-listner-db5432" comment/uncomment 

- pgadmin.medchg.com:5434
	- public connection for production db server cluster
	- username : postgres
	- password : uN3i1Hh0bYbCc4TyVAacBhmSzgqtzqxmOVjAn0QIChsJrSmu9PY2fw2q8EKKLpZ9
	- maintainance database: postgres
	- to enable/disable use terraform apply command
		- https://github.com/eSpark-Consultants/medchg_infra/blob/main/terraform/9-nlb.tf
		- find section with resouce "k8s-listner-db5434" comment/uncomment 
		
- https://gitops.medchg.com/ 
	- gitops manager
	- username : admin
	- password : fw6t6TRPJ873s4ys
	- to disable weburl: login to k8s master node run k9s command goto ingrees then delete argocd-server-http-ingress

## create/delete/update medchg application 

### method 1 k8s master create/delete
- follow guide https://github.com/MedchgDev/medchg-production_cd

### method 2 only delete 
- login https://gitops.medchg.com/ 
- delete application 

### Update medchg application deployement like db password, URL, Environment varables 
- update any thing here https://github.com/MedchgDev/medchg-production_cd/tree/main/src/web
- commit 
- wait for 2 minutes  argocd will authomatically update deployement
- check update status https://gitops.medchg.com/ 

### GitOps application deployement mechanism 

# setup Infra
https://github.com/eSpark-Consultants/medchg_infra/tree/main/terraform


# login to k8s 
ssh -i ~/.ssh/id_rsa ubuntu@54.173.205.211 #bastian
ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.221 #master 
ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.227 #worker1
- ssh file https://github.com/eSpark-Consultants/medchg_infra/ssh

# Status
- [ ] K8s Infra
	- [x] EC2 Security 
		- [x] SSH only via bastian 
		- [x] Private Subnet
	- [ ] Services
		- [x] CNI Calico
		- [x] ArgoCD
			- [x] ingress
				- [x] lets encrypt TLS
			- [x] Image updater
		- [x] Storage Class
			- [x] local-path # local provisioner
		- [x] NGINX Ingress
		- [x] Test Deploy (for testing)
		- [x] Cert Manager
			- [x] Tested Lets Encrypt 
		- [x] CNPG Posgress Clusters
			- [x] stg/dev
			- [x] prod
				- [x] daily mid-night Schedule Backup AWS S3 Cloud
					- https://us-east-1.console.aws.amazon.com/s3/buckets/k8s-backup-231224
				- [x] Local storage PV 
				- [x] User can access db via pgadmin.medchg.com:5434
		- [x] PGAdmin Web point to pgadmin.medchg.com
			- [x] SSL letsencrypt using cert manager
		- [x] Applications	
			- [x] medchg
				- [x] CI
					- https://github.com/MedchgDev/medchg-production
				- [x] CD
					- https://github.com/MedchgDev/medchg-production_cd
					- [x] Pod
						- [x] image pull secret 
							- [x] Job 
							- [x] CronJob
						- [x] Mount
							- [x] TLS certificate  
						- [x] env
							- [x] DB
					- [x] ingress
						- [x] TLS
					- [x] Envirments 
						- [x] Dev https://dev-k8.medchg.com/
						- [x] STG https://stg-k8.medchg.com/
						- [x] PROD https://medchg.com/
				
	- [x] Terraform
		- [x] SSH
		- [x] VPC
		- [x] Security Groups
		- [x] Subnets
		- [x] S3
			- [x] S3 policy
			- [x] S3 backup User
		- [x] ECR
			- [x] ECR policy
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
			- [x] gitops
			
# Setup k8s master and worker cluster 
- ssh -i ~/.ssh/id_rsa ubuntu@54.173.205.211 #bastian
- ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.221 #master 

## master k9s ui
wget https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_linux_amd64.deb
sudo apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb

## init cluster
IPADDR=$(hostname -i)
POD_CIDR="192.168.0.0/16"
sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

		
## install CNI flanel
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
# Install calico better performance 
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml


## install helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

## ALias user specific
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

## join workers commands
kubeadm token create --print-join-command # master
sudo kubeadm join 10.0.20.221:6443 --token 83ky3x.ehj3r7w85qq1e7q4 \
        --discovery-token-ca-cert-hash sha256:12f737935485b6c316c406258b6e7b9db96e9dcc6f0f045e1ebcef320e30cf50


## for services 
cd
cd services/nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx --values values.yaml ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace 


cd
cd services/cert-manager
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.16.3 \
  --set crds.enabled=true
kubectl apply -f prod.yaml
kubectl apply -f stg.yaml

cd
cd services/storageclass
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml

cd 
cd services/cnpg
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml

wait .....  
cd services/cnpg/dev
kubectl create namespace cnpg-stg
kubectl apply -f deploy.yaml

cd
cd services/cnpg/prod
kubectl create namespace cnpg-prod
kubectl apply -f deploy.yaml
kubectl create secret generic aws-s3-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=AKIA4GX3SSVUNMZ3BHXH \
  --from-literal=AWS_SECRET_ACCESS_KEY=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 -n cnpg-prod

cd
cd services/cnpg/pgadmin
kubectl create namespace cnpg-pgadmin
kubectl apply -f cert.yaml
wait...
kubectl apply -f deploy.yaml

cd 
cd services/argocd
kubectl create namespace argocd
kubectl apply -n argocd -f deploy.yaml

wait  .... 

kubectl apply -f ingress.yaml

wait.... 

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
cd 
cd services/argocd/imageupdater
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd-image-updater --values values.yaml argo/argocd-image-updater -n argocd

 

## SSH keep alive
nano $HOME/.ssh/config
Host *
    ServerAliveInterval 500
	
chmod 600 ~/.ssh/config	

# update pv worker ip 
# copy services folder for kubernates to bastian 
cd /mnt/d/Projects/espark/knozi/k8s
scp -r services ubuntu@54.173.205.211:./ #bastian
scp ~/.ssh/id_rsa ubuntu@54.173.205.211:~/.ssh/ #bastian

ssh -i ~/.ssh/id_rsa ubuntu@54.173.205.211 #bastian
sudo chmod 400 ~/.ssh/id_rsa

# copy services folder for kubernates to bastian 
scp -r services ubuntu@10.0.20.221:./ #master 



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





## ec2 ecr testign 
ctr image tag docker.io/library/python:3 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:3
ctr image push 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:3
ctr image ls | grep  k8s-services
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 839119967592.dkr.ecr.us-east-1.amazonaws.com


docker pull docker.io/nginxdemos/hello:latest
docker tag docker.io/nginxdemos/hello:latest 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:latest
docker push 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:latest
ctr images pull 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:latest

docker tag testblazor:v1 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:v1
docker push 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:v1


aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 839119967592.dkr.ecr.us-east-1.amazonaws.com
aws ecr get-login-password --region us-east-1 | ctr   login --username AWS --password-stdin 839119967592.dkr.ecr.us-east-1.amazonaws.com
aws ecr get-login-password --region <region> | ctr images registry login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com

aws ecr get-login-password --region us-east-1 | ctr images auth --username AWS --password-stdin 839119967592.dkr.ecr.us-east-1.amazonaws.com

aws ecr get-login-password --region us-east-1 | buildah login --username AWS --password-stdin 839119967592.dkr.ecr.us-east-1.amazonaws.com


### test working commands
ctr image pull 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:latest
ctr image pull --user "AWS:$(aws ecr get-login-password --region us-east-1)" 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:stg-v46

mkdir -p /etc/containerd/certs.d/839119967592.dkr.ecr.us-east-1.amazonaws.com

scp -r argocdtest ubuntu@54.173.205.211:./services/cnpg #bastian
scp -r ./cnpg ubuntu@10.0.20.221:./services/cnpg #master 	  

read -rs gitpassword
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
export gitpassword

git clone https://$gituser:$gitpassword@github.com/smhrazaespark/argocdtest.git
 
helm upgrade --install -f values-prod.yaml prod-argocd .


aws ecr --region "us-east-1" get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64

sudo systemctl restart containerd		 

echo -n 'Hello, World!' | base64
echo -n aws: | base64