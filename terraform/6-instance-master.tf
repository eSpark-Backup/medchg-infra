resource "aws_iam_instance_profile" "k8s-master-s3-backup-profile" {
  name = "k8s-master-s3-backup-profile"
  role = aws_iam_role.k8s-s3-backup-access-role.name
}

resource "aws_instance" "k8s-master" {
  ami           = var.k8s_master_ami
  instance_type = "t3.small"
  iam_instance_profile = aws_iam_instance_profile.k8s-master-s3-backup-profile.name
  subnet_id = aws_subnet.k8s-private.id
  vpc_security_group_ids = [aws_security_group.k8s-private-ssh.id, aws_security_group.k8s_common_sg.id]
  key_name = aws_key_pair.k8s_key.key_name
  user_data = templatefile("k8s_comman_dependencies.sh", {})    
  root_block_device {
    volume_size = 20  
    volume_type = "gp2" 
  }   
  tags = {
    Name = "k8s-master"
	"kubernetes.io/cluster/${var.CLUSTER_ID}" = "owned"
  }
}