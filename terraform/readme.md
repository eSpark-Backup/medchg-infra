
# prereq
# on windows 
- setup wsl environment prefered ubuntu 
- open terminal in windows --> ubuntu.exe run
- ssh-keygen -o # note file name and pass phrase (default filename for ssh is configured in terraform script is "id_rsa")
- cd terraform script directory 
sudo apt update
sudo apt install gh
gh auth login
cd medchg repo folder 
gh secret set aws_ci_bot_access_key --body $(terraform -chdir="/mnt/d/Projects/espark/knozi/k8s/terraform" output -raw aws_ci_bot_access_key)
gh secret set aws_ci_bot_access_secret --body $(terraform -chdir="/mnt/d/Projects/espark/knozi/k8s/terraform" output -raw aws_ci_bot_access_secret)
gh secret set PAT --body $(echo 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) # smhrazaespark/medcjhrd
	gh secret set PAT --body $(echo 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) # production/medcjhrd
# for creation
terraform apply 

# for destruction 
terraform destroy

# get s3 access credentials 

