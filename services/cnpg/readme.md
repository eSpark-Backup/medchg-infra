kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
  
kubectl create namespace dev-cnpg  
kubectl create namespace cnpg-pgadmin