resource "aws_instance" "k8s_workers" {
  ami           = var.k8s_worker_ami
  instance_type = "t3.medium"
  count           = var.workers_count
  subnet_id = aws_subnet.k8s-private.id
  vpc_security_group_ids = [aws_security_group.k8s-private-ssh.id, aws_security_group.k8s_common_sg.id, aws_security_group.k8s_workers_sg.id]
  key_name = aws_key_pair.k8s_key.key_name
  user_data = templatefile("k8s_comman_dependencies.sh", {})    
  root_block_device {
    volume_size = 30  
    volume_type = "gp2" 
  }   
  tags = {
    Name = "k8s_workers"
	"kubernetes.io/cluster/${var.CLUSTER_ID}" = "owned"
  }
}