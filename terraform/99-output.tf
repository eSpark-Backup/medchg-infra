output "k8s-bastion_public_ip" {
  value = aws_instance.k8s-bastion.public_ip
}
output "k8s-master_private_ip" {
  value = aws_instance.k8s-master.private_ip
}
output "k8s_worker_private_ip" {
  value = aws_instance.k8s_workers[*].private_ip
}
output "aws_access_key_id" {
  value = aws_iam_access_key.k8s-s3-backup-creds.id
}
output "aws_secret_access_key" {
  value     = aws_iam_access_key.k8s-s3-backup-creds.secret
  sensitive = true
}
