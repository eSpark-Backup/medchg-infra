# how to deploy k8s infra
- working directory /mnt/d/Projects/espark/knozi/k8s
- clone repo main branch https://github.com/eSpark-Consultants/medchg_infra

# prereq
# on windows 
- setup wsl environment prefered ubuntu 
- open terminal in windows --> ubuntu.exe run
- ssh-keygen -o # note file name and pass phrase (default filename for ssh is configured in terraform script is "id_rsa")
- cd terraform script directory 

# for creation
terraform apply 

# for destruction 
terraform destroy

# only for github action secrets CI Setup
- this section describe if developer wants to set AWS ECR credentials for CI pipeline 
- git clone https://github.com/MedchgDev/medchg-production
- cd medchg repo folder 
- sudo apt update
- sudo apt install gh
- gh auth login
- gh secret set aws_ci_bot_access_key --body $(terraform -chdir="/mnt/d/Projects/espark/knozi/k8s/terraform" output -raw aws_ci_bot_access_key)
- gh secret set aws_ci_bot_access_secret --body $(terraform -chdir="/mnt/d/Projects/espark/knozi/k8s/terraform" output -raw aws_ci_bot_access_secret)
- gh secret set PAT --body $(echo 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) # https://github.com/MedchgDev/medchg-production

# get s3 access credentials if required 
- terraform output -raw aws_s3_backup_access_key
- terraform output -raw aws_s3_backup_access_secret
