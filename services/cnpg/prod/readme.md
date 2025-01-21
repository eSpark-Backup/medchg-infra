kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
  
kubectl create namespace cnpg-prod
k apply -f deploy.yaml

# get access ikey and secrete 
- run from terraform 
- terraform output aws_secret_access_key

# s3 create k8s-backup-231224/dbbackup-prod

kubectl create secret generic aws-s3-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=AKIA4GX3SSVUNMZ3BHXH \
  --from-literal=AWS_SECRET_ACCESS_KEY=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 -n cnpg-prod