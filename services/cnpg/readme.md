mkdir cnpg 
cd cnpg 
nano deploy.yaml 

kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
  
kubectl create namespace dev-cnpg  
k apply -f deploy.yaml
kubectl create namespace cnpg-pgadmin


kubectl create secret generic aws-s3-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=AKIA4GX3SSVUIFGNWNPE \
  --from-literal=AWS_SECRET_ACCESS_KEY=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 -n dev-cnpg  