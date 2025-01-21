output "k8s-bastion_public_ip" {
  value = aws_instance.k8s-bastion.public_ip
}
output "k8s-master_private_ip" {
  value = aws_instance.k8s-master.private_ip
}
output "k8s_worker_private_ip" {
  value = aws_instance.k8s_workers[*].private_ip
}
output "aws_s3_backup_access_key" {
  value = aws_iam_access_key.k8s-s3-backup-creds.id
}
output "aws_s3_backup_access_secret" {
  value     = aws_iam_access_key.k8s-s3-backup-creds.secret
  sensitive = true
}

output "aws_ci_bot_access_key" {
  value = aws_iam_access_key.k8s-ci-bot-creds.id
}
output "aws_ci_bot_access_secret" {
  value     = aws_iam_access_key.k8s-ci-bot-creds.secret
  sensitive = true
}
