kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
  
kubectl create namespace cnpg-stg
k apply -f deploy.yaml

# get access ikey and secrete 
- run from terraform 
- terraform output aws_secret_access_key

## no need in dev stg
kubectl create secret generic aws-s3-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=AKIA4GX3SSVUNMZ3BHXH \
  --from-literal=AWS_SECRET_ACCESS_KEY=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 -n cnpg-stg