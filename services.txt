
# https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
nano values.yaml 
helm install nginx --values values.yaml ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace 
helm upgrade nginx --values values.yaml ingress-nginx/ingress-nginx -n ingress-nginx 

#kubectl taint nodes --all node-role.kubernetes.io/master-
#kubectl taint nodes --all  node-role.kubernetes.io/control-plane-

#kubectl label nodes ip-172-31-27-215 dedicated=master


resize ec2 
sudo lsblk
sudo growpart /dev/xvda 1
if ex4t
sudo resize2fs /dev/xvda1



helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.12.0 --set installCRDs=true