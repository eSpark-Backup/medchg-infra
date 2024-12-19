
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
default = "us-east-1"
}
variable "k8s_bastian_ami" {
  type    = string
  default = "ami-005fc0f236362e99f"
}
variable "k8s_worker_ami" {
  type    = string
  default = "ami-005fc0f236362e99f"
}
variable "k8s_master_ami" {
  type    = string
  default = "ami-005fc0f236362e99f"
}
variable "workers_count" {
 type        = number
 default     = 1
}
variable "vpc_All_cidr_block" {
  description = "CIDR (Classless Inter-Domain Routing)."
  type        = string
  default     = "0.0.0.0/0"
}
variable "vpc_public_cidr_block" {
  description = "CIDR (Classless Inter-Domain Routing)."
  type        = string
  default     = "10.0.10.0/24"
}
variable "vpc_private_cidr_block" {
  description = "CIDR (Classless Inter-Domain Routing)."
  type        = string
  default     = "10.0.20.0/24"
}
variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "awsprops" {
    type = map
    default = {
    ami = "ami-022b0631072a1aefe"
    itype = "t3.micro"
    publicip = true
    keyname = "awskey"
  }
}
variable "CLUSTER_ID" {
  type    = string
  default = "kubernetes"
}