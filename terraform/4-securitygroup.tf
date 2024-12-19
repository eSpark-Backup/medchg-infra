resource "aws_security_group" "k8s-bastion-allow-ssh" {
  vpc_id      = aws_vpc.k8s-vpc.id
  name        = "bastion-allow-ssh"
  description = "security group for bastion that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "k8s-bastion-allow-ssh"
  }
}

resource "aws_security_group" "k8s-private-ssh" {
  vpc_id      = aws_vpc.k8s-vpc.id
  name        = "k8s-private-ssh"
  description = "security group for private that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.k8s-bastion-allow-ssh.id ]
  }
  tags = {
    Name = "k8s-private-ssh"
  }
}
# Create a Security Group
resource "aws_security_group" "k8s_common_sg" {
  vpc_id      = aws_vpc.k8s-vpc.id
  name        = "k8s_common_sg"
  description = "K8s node secuirty group"
  tags = {
    Name = "k8s_common_sg"
  }
}
resource "aws_security_group" "k8s_master_sg" {
  vpc_id      = aws_vpc.k8s-vpc.id
  name        = "k8s_master_sg"
  description = "K8s node secuirty group"
  tags = {
    Name = "k8s_master_sg"
  }
}
resource "aws_security_group" "k8s_workers_sg" {
  vpc_id      = aws_vpc.k8s-vpc.id
  name        = "k8s_workers_sg"
  description = "K8s node secuirty group"
  tags = {
    Name = "k8s_workers_sg"
  }
}


# Add rule to allow kube-api access (port 6443)
resource "aws_vpc_security_group_ingress_rule" "k8s_allow_6443_ipv4" {
  security_group_id = aws_security_group.k8s_common_sg.id
  cidr_ipv4         = var.vpc_private_cidr_block
  from_port         = 6443
  ip_protocol       = "tcp"
  to_port           = 6443
  tags = {
    Name = "k8s_allow_6443_ipv4"
  }
}

# Add rule to allow etcd communication (port 2379)
resource "aws_vpc_security_group_ingress_rule" "k8_allow_2379_ipv4" {
  security_group_id = aws_security_group.k8s_common_sg.id
  cidr_ipv4         = var.vpc_private_cidr_block
  from_port         = 2379
  ip_protocol       = "tcp"
  to_port           = 2379
  tags = {
    Name = "k8_allow_2379_ipv4"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_8080_ipv4" {
  security_group_id = aws_security_group.k8s_common_sg.id
  cidr_ipv4         = var.vpc_private_cidr_block
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  tags = {
    Name = "k8_allow_2379_ipv4"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_80_ipv4" {
  security_group_id = aws_security_group.k8s_common_sg.id
  cidr_ipv4         = var.vpc_private_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  tags = {
    Name = "k8_allow_2379_ipv4"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_http_ingress" {
  security_group_id = aws_security_group.k8s_workers_sg.id
  cidr_ipv4         = var.vpc_All_cidr_block
  from_port         = 32080
  ip_protocol       = "tcp"
  to_port           = 32080
  tags = {
    Name = "k8_allow_http_ingress"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_db30543" {
  security_group_id = aws_security_group.k8s_workers_sg.id
  cidr_ipv4         = var.vpc_All_cidr_block
  from_port         = 30543
  ip_protocol       = "tcp"
  to_port           = 30543
  tags = {
    Name = "k8_allow_db30543"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_https_ingress" {
  security_group_id = aws_security_group.k8s_workers_sg.id
  cidr_ipv4         = var.vpc_All_cidr_block
  from_port         = 32443
  ip_protocol       = "tcp"
  to_port           = 32443
  tags = {
    Name = "k8_allow_https_ingress"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_443_ipv4" {
  security_group_id = aws_security_group.k8s_common_sg.id
  cidr_ipv4         = var.vpc_private_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  tags = {
    Name = "k8_allow_2379_ipv4"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_8443_ipv4" {
  security_group_id = aws_security_group.k8s_common_sg.id
  cidr_ipv4         = var.vpc_private_cidr_block
  ip_protocol       = "ALL"
  tags = {
    Name = "k8_allow_8443_ipv4"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_kubelogs_ipv4" {
  security_group_id = aws_security_group.k8s_common_sg.id
  cidr_ipv4         = var.vpc_private_cidr_block
  from_port         = 10250
  ip_protocol       = "tcp"
  to_port           = 10250
  tags = {
    Name = "k8_allow_kubelogs_ipv4"
  }
}


resource "aws_security_group" "k8s_nlb" {
  vpc_id      = aws_vpc.k8s-vpc.id
  name        = "k8s_nlb"
  description = "k8s_nlb"
  tags = {
    Name = "k8s_nlb"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_nlb_http" {
  security_group_id = aws_security_group.k8s_nlb.id
  cidr_ipv4         = var.vpc_All_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  tags = {
    Name = "k8_allow_nlb_http"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_nlb_https" {
  security_group_id = aws_security_group.k8s_nlb.id
  cidr_ipv4         = var.vpc_All_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  tags = {
    Name = "k8_allow_nlb_https"
  }
}
resource "aws_vpc_security_group_ingress_rule" "k8_allow_nlb_db5432" {
  security_group_id = aws_security_group.k8s_nlb.id
  cidr_ipv4         = var.vpc_All_cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
  tags = {
    Name = "k8_allow_nlb_db5432"
  }
}

