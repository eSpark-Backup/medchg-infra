resource "aws_instance" "k8s-bastion" {
  ami           = var.k8s_bastian_ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.k8s-public.id
  vpc_security_group_ids = [aws_security_group.k8s-bastion-allow-ssh.id]
  key_name = aws_key_pair.k8s_key.key_name 
  tags = {
    Name = "k8s-bastion"
  }
}