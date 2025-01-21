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

ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.221 #master 

ssh -i ~/.ssh/id_rsa ubuntu@10.0.20.227 #worker1

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
		- [x] ArgoCD
			- [x] ingress
				- [x] lets encrypt TLS
			- [x] Image updater
			- [x] Tests
				- [x] Complete Gitops cycle with auto image update 
					- [x] ArgoCD Application 
					- [x] github credentials pattern
					- [x] Amazon ECR pattern
					- [x] Helm chart for ArgoCD apllication deployment
					- [x] Helm chart for apllication deployment
					- [x] Prod and Dev environments segregation with image filtering
		- [x] Storage Class
			- [x] local-path # local provisioner
		- [x] NGINX Ingress
		- [x] Test Deploy (for testing)
		- [x] Cert Manager
			- [x] Tested Lets Encrypt 
		- [x] CNPG Posgress
			- [x] stg/dev
			- [x] prod
			- [x] Local storage PV 
			- [x] User can access db via pgadmin.medchg.com:5432
			- [x] Cloud backup on demand
			- [x] Cloud backup periodic
		- [x] PGAdmin Web point to pgadmin.medchg.com
			- [x] SSL letsencrypt using cert manager
		- [ ] Applications	
			- [ ] medchg
				- [ ] CI
					- [x] Tested with github local repo
				- [ ] CD
					- [x] Tested with github local repo
				
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


### working commadns
ctr image pull 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:latest
ctr image pull --user "AWS:$(aws ecr get-login-password --region us-east-1)" 839119967592.dkr.ecr.us-east-1.amazonaws.com/k8s-services:latest

mkdir -p /etc/containerd/certs.d/839119967592.dkr.ecr.us-east-1.amazonaws.com

[plugins."io.containerd.grpc.v1.cri".registry]
  config_path = "/etc/containerd/certs.d"
  
    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""
      [plugins."io.containerd.grpc.v1.cri".registry.auths]
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."839119967592.dkr.ecr.us-east-1.amazonaws.com".tls]
          insecure_skip_verify = false
        [plugins."io.containerd.grpc.v1.cri".registry.configs."839119967592.dkr.ecr.us-east-1.amazonaws.com".auth]
		  username = "AWS"
          password = "eyJwYXlsb2FkIjoiZUNUb1dwM28yc2RJL0FrNWV4dGNBZWR2SXdQdmY4OGNnUVlQMzRJNXRXQTFDVDJnREhSdE1iY0lrVmErc1dRbVJGL2VwSElEbExxNlZCSFFSSVNYRWxBcTJEVDgrS2tIdlVQdjRUUFNiTUhCelFBUVNqZ2dTYlJ1bW5PQjUvRFAzOFdIWnZNdm55cTlhUE51OXBTYThmc2pYNktIb0FMb1ZIcjM5Zk01a3NtQ1FYN3Y5VkNHak9SQWdWRXlFRTBGVkNlVTgwbERMbGxCUGRINGxpendRcERwMnJlb2xENjlDN243YnliNjhucEdyNVgxL3lDRVdZNDlXb1dDNTJtYXlpMytubDcxRjFkc0VTWHFZNW55SWUyb084ODAxTjZQTXVLM2JWQncxSnRBWGwwVTNyZ245Z1pHVll0YVBSV1VPTGp6dTdpdW1pZG43RDE4WDdKL3J0VWU5T3ViM2tnZnhlV1FVN1k4UmhXRlgyN2RjbVdzR1Eyem5Hd2VnRU1zZmhwMCtlTnRkclorb2dsUmk3ZHBMa3hQUHJtampSdDREOHpSdkpWcGVRdGJENzcxZk9acHBoQWk2TEEyRSt0aEVQR0tlUHpFWkE1YUJpOXdwUU9oWERWOStZYStzeEJMdForQU83Y0w5N0JVeUFzMTQxbWgvWjlUaUtJNmRDa1FJZ0U3OXZpZXIvT0hKNmJqRlVqOC93a0NLRGJzQ25CYWpYYXBYYkt1UHdlbmF0M1RQbm83ckIzUFdnQzZRUkRTZytQSXpQMFBUNmVJd3EzbVp3U1pQZ3dZeXI5clJzYnJxajhRVTVwU1cxVElqbTQzNDc1UElQRU9RTVMxNzh0aFB2azlHNC9BR25PUHJVZ0RuQzNwSVhydmVRRlRhSVJMa1UxVXRXek9KdzgxUURuOHRJeFBuNUNpaWlUM21DYk1xbE5GUUxVQzlqOStnTUJYai9uM1pQOGlnenEyQVBsaGc5Wk92THJ3UnhNdFZnY05VbWdrR3BrSEVJdFI4VzFxVXFlYndoWHUrNkdyOFI5L0dNTnFaRjhjbm1XWjRXd01SdUJGZk01WWtvN2pEY0hQbWNERW42ZllhVXhpWTdiTHZoWDJkeEl5MXZsNEhLOXdVUzZ5d2ZmMWRjWHB5STJEUmt1YVpHZFFJRjQ3alNoV3NJM2lNQmNOc3NFQVFWREJNZjFvK3hBZXlGRXoxMTlSZ3lWUXFvRG1xYVg5NnlDbngvTjJiMVJqM2FPbUxqQ3UzeWVQQ3RpZ1B2OVc5ekRBdGRuMk9QR3J0d0djd2RvWGdNdGxnS0lnUjh3eGQyRE5SemFLLzlhcytYQTcvVWtjK1hxVUl4QjhNdUkxckdEbzYwbVlGRVRjWE1HZzEvMWNXdXlpRkE4aXMybXZHY2NlZTlubXE0T3NIN3oyQUFHWkFMclBmc3RJRWN2dXVXNUx1b1YvTlBsbDN5OGVjb25TSWVLKzdJeTFRbTJjcy85ZGVBUzRYUWttU0cvWU16ZEFZbTJEZE1acUFyOTJoRUZJSWFOZVh4ZTJOcXpWMUNwQlRsVUtRTkh2bTF4Y2MxdEhveXcyMCtwejV4Y3lXL1NMa2R2TWFMMmFIcDBsQjNxelNIMW5kWUVkOHAzTmNyTUswZFFZM2pkUHkrZk4wWDZLcEE3U1d6S1h5SmZlLytpRXErNTUxbFI3SExycXZHVFdlSUVWRDZjUm4vcGxYRVFLbTBwRXNxSDNQNWZmaHk4Lys3VDRERjNnUFB6SzU1ck83V1FXZitlTnJXWFFETWJnNXQ0dFB5YmFaNmhsMUtYeUdNK0FDc2N3c1hwNnFRYjlnWnl4bVNtWGRCOUFxSmlMaWxJNGFvZFZIbU9xQnRSdUh1Smd5eGtIa29qcWc0emdZK094YmsyRitxdnp1NHRKZFhPalQwWVRSRWJzeDUrZU1PT2JGQjBvK1JwYVNuL2NBTkJMY2xqdHh4d2pwYW96bnVqL3BzMW14QVRmN2pFUEJGZFpRa0JaREhOZzJQczJxYlRPRmVuSkJ0SGV4cS9GdzVmVkM1Z1hBRVo5eEZta1NEZ0w3dDZyNDNwWm92MkhWZUs0U3V1Y3IvYlJJMkppWnJmb21SL2ZTaEwycFJSZXp2L1BDckU2M1YxN1JhZFpCdUdwSWJVZ3ZQNHJDTlE2VnFQMGk1OXRhbDdWYU00NmtZVElVZ0FWampJM0ZaVk1yUS9lUG1SNHpzUnZIYkdWN1U3TTBkc1pBTzU1a3kxWnpPYk4zbnVWc0ZoaDJHL1lWaVBiWDZiVVlZVjBQVlg1cWgrV1hlcWhwWkxUNzcyUy9scDI1N1g2YUNDdEdTQkZORUxxQko4Z2RaYStQeDdjQXNISGJXQSt2NHlxdmRXWFVTSnNBUWxER3EzL1M4NGJ1eUV2ZHhxcnljODBjdGlrQ3RvTnlIM3IyQ0dvbjBlRHFKa05Gc1lRZEhxNDJOQkV1RWhmQTV5ckFhK2h6ejBhRXJ4V01jR3pqemdpNkxKNkRWSUZIMmRSWWJSYyIsImRhdGFrZXkiOiJBUUVCQUhod20wWWFJU0plUnRKbTVuMUc2dXFlZWtYdW9YWFBlNVVGY2U5UnE4LzE0d0FBQUg0d2ZBWUpLb1pJaHZjTkFRY0dvRzh3YlFJQkFEQm9CZ2txaGtpRzl3MEJCd0V3SGdZSllJWklBV1VEQkFFdU1CRUVEQjRHTkhMVk1MNmFOdHlvYlFJQkVJQTc2dDhqNDJnZC9zQ2lad2VraFFjV21KanVTZXNCQ2Uwb2tna2ZIV3VGd2RSOFpFZTg0RXoxRFBSTEUwUEU1UWMwR1BPTmNkWFBRZnRtZlVrPSIsInZlcnNpb24iOiIyIiwidHlwZSI6IkRBVEFfS0VZIiwiZXhwaXJhdGlvbiI6MTczNjM4NzM0NH0="
      [plugins."io.containerd.grpc.v1.cri".registry.headers]


    [plugins."io.containerd.grpc.v1.cri".registry]
	  [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
	    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
		  endpoint = ["https://registry-1.docker.io"]
		[plugins."io.containerd.grpc.v1.cri".registry.mirrors."839119967592.dkr.ecr.us-east-1.amazonaws.com"]
		  endpoint = ["https://839119967592.dkr.ecr.us-east-1.amazonaws.com"]
	  [plugins."io.containerd.grpc.v1.cri".registry.configs]
		[plugins."io.containerd.grpc.v1.cri".registry.configs."839119967592.dkr.ecr.us-east-1.amazonaws.com".tls] 
		   insecure_skip_verify=fa
	  [plugins."io.containerd.grpc.v1.cri".registry.configs."839119967592.dkr.ecr.us-east-1.amazonaws.com".auth]
          auth = "AWS:eyJwYXlsb2FkIjoiMTJ2VkRlSXBtWXQ3M1psTlZUNE9OYmZ0YWN6aXJZWkJBbjZWV0syd1FkN1M1Y2VaRjdvV3cxclNhemhESnAzSE1leFBmU3UxRUlha2lYclZGMlNiREZUOEw5N012aGlLdFB1YllrakR2Ri9rUXJ5T01ISEtMMHU4bzlQU2E3VUQya1JqSWJUejl3bkNvOHZ6VHY3eWY1ZXBnaHV0NGkzZFU1cjRicm5EZmlGOFlwdGZtWnl5NWRyUnNhWmdzZlhOT1RCM0taVDI2dldCM3lsS2pDVUp0QVd0bkZJRzFqY3U1b0FjZDBGTzdUSmtpSmxCTm5XWkN0TnVMaHExVS9DbUplcWdBVjBidXFIWDE0OVZVOG5TMVVsTW1rUGJmZ2srbWt2cWZjWW1QbWkySkhiN1F2TkVveDExRGpuSnB3eXhKQTBiMTVTR1NJVlJYVG4vYUg0MnZ5NFpSUjBQL3VVaTM2TVF0clBVZXpVaUhwT1NmZXlaZk4xNmpZVitTdjVnWlowYUlvcDl4b3ZkOHQwdjlNZ2RTcWJJK0hHTFUrY0g1WnNhQ0QwMzZjZktqaks1c3IxMVMvL2ZvdHFyOHFVV3ZWNG4wLytac1hvK2luditIUy9CYjAvVC9vM0xRclJtTjdxbkp0K09QdmJ3SGxqNTJhZjZxeW42bnlyTnFRZ3RVbWtNbkZha2VRMWR0OEM1aVdGQm1XMkY4cnI4eGJFZ1VmYXl2RDVhYkhyTG9HRnRuWWdOZkdyMDFaeGZEMGhGK0kxYlZQVVA2UFMxOWt2SDZHTzc0Ty9uMVY0NHZCcDEyVU04dE1DQks4UXpqUCtiTEplSUx4bklpdlRQNE90aUc2OFQ0UnJmYkZicnVxOW9TYUxXcStJV2RaMFVmQ0ovZ0lLOGdiS1BtWWVCbTNXaEtoQ0JIZHovSytGa3NyQTRSUTI4ckZ4UmpwUzU4Nitra2JjRm10TlhEU0ptZ2NNWkVNMFNEUlRkbzk4S1NQTGpaT0RpRjNhL21aYjJyM200dTNxM3prV1VWTFlTQzRVQ0FDSWhGQkZmZmV6WE4wZXUrazhqS3ZUbzVvRXgwM3FaTkcwR3FSandZTGJJNFdhTHJwTlVvdEJ5Zi9MUUhlUFFLaVpyR3ZVZlNRRTJkbmNwMEVhZ3hkb1N0UVdVeG5HbGxBSUFWcnhhWEtFeTVqSFIxTnYrVUNyYTY3cmFzaVQ5d0JFR2hsNksrcmFwU3k2ZWVRRWlsdG85enRBWTZIQzdOdW5IVSt6bk5uZ2drbWVzOWhJTlB6SUV5NHZBeENjaC9KV0EwalN5YktlaTA2a2szb3ZjZVU1RjNtM0NueW1JeDBWVU9iSjFGNmZsa3gwZ0xuTUI3RVEwN3JyUm8ybHMvV3NGMW1TZlFnVEo2QjVUR1FHMVZhNWE5ZmZnT0I5ZXZsN3d1Zml0NVFGNUpGdGNCRXZYeGdIaFBMSTFYSHRJc0hVcFZQdCt5S3B6WEFGYkhEUlhnTE45WEJMTk1DTGNiUVpRSWgvcmNKVUlQc0J0R2xXZlpPaDFCWCtFM3hyMzFERWF2Uldqa0ptRG9GeUhDU0hLMzhOSHFUd2NPV2FxU0xDV29XZTE0OXR2MjVmYUdwSHRTMXhBYmJ4aFg4YnQxY0J0WHZqbmE5VFJxVzUyUmtQd3VVYVZjMjZPVEJVbjZ5SHV2ck5BakpkTitIc3VlQjczSFhsaDgzemxYNFNTOVdBZUhCRDg2bS9LcWpYMXZrSTBRdTZCczU0dVZ2UlpiQnVFODUyRjJ1b2tiQWlIRllkL2ZndCs5Z0ZXK0xKRzJzaks3RVJGbXhHUTRHcVA2VGhaekdMQ2pBUGxGQzUySUU0d3BRTXhQVytCWWRGN0QwQXdFNHV2eDMvYzZjNEkyOHZsUmRORHJmVXdlaEtlTklhU21Sb3MyYWtKdGhWdlNvTkw4VHhiekZIL1R3RzBnMXFjU283NGROd2gyRXFQVU50T0ZZUDdYcStSd25lSlg4MmdTK3VjZkpNSGFNeGlWb1dySWxCTis5NFNUeU1UVXpsSTF0MUQ1UFRJVStKdWZ1U0ZkMXdoeVc5S1lROFFtN0dGMzg2a1EvQmdPaHJRTlA3Y2Y1ZGN5V3NsaVFrS1VvZWpjeW1xSXpBbXpQb2pHYWVzeHdxNkpkQVptMWpDYWViMVdFejRKVk1BRHpKL0xSR2dBR3lMK1REeWZDWkdLY3RReC9QRmVtS011dzYySTdlVXppY3EwVjhLaFJyQXhQc2lJYjJYY2UwT2QzR3RMdDJBRUU1TGZIdFd3cVNjWmxFR0pIWExybWpZKyszeUVxWlZrUldJZlZPWlF5ak1DUTh4a0dtMUdybnJZWmQyeFVXaXExdUdxZ2U5b0piTnVCQjRZRXI3Q3Y4dk1sVzRwbk5pMVNubEMwS0Z3VVdSUUtnZHIvOXVudDI2aWZ6YXl0M1hoZDJLVjV1MDZpVkUyODRtR09UemczOFh2cVF4VERwenRGN2djSml6WG5yblJpUy83bmJoSm9VNSIsImRhdGFrZXkiOiJBUUVCQUhod20wWWFJU0plUnRKbTVuMUc2dXFlZWtYdW9YWFBlNVVGY2U5UnE4LzE0d0FBQUg0d2ZBWUpLb1pJaHZjTkFRY0dvRzh3YlFJQkFEQm9CZ2txaGtpRzl3MEJCd0V3SGdZSllJWklBV1VEQkFFdU1CRUVESTB6dWFxVDcyakU5U0VjN1FJQkVJQTd5ZEwzbDZNUkhqN3pHcG5ueGt1REdwRVc5TnNSOTVWWE5SUXlZT0pBWW45SVNjbDRPSkMvRVZoU3kxdjhBV3FzYm4xZFFxNjgzMHZLVVpNPSIsInZlcnNpb24iOiIyIiwidHlwZSI6IkRBVEFfS0VZIiwiZXhwaXJhdGlvbiI6MTczNjM4ODYyM30="


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