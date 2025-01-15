kubectl create namespace recovered-cnpg


kubectl create secret generic aws-s3-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=AKIA4GX3SSVUNMZ3BHXH \
  --from-literal=AWS_SECRET_ACCESS_KEY=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 -n recovered-cnpg