output "k8s-bastion_public_ip" {
  value = aws_instance.k8s-bastion.public_ip
}
output "k8s-master_private_ip" {
  value = aws_instance.k8s-master.private_ip
}
output "k8s_worker_private_ip" {
  value = aws_instance.k8s_workers[*].private_ip
}