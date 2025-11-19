variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "resource_group" {
  description = "Logical resource group name applied to all created resources as tags"
  type        = string
  default     = "tf-resource-group"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "12.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "12.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "12.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance (e.g. your public IP in /32). Do NOT leave as 0.0.0.0/0 in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_key_path" {
  description = "Path to your public key file on your local machine (used to create AWS keypair). Example: ~/.ssh/id_rsa.pub"
  type        = string
  default     = "~/.ssh/ec2_key.pub"
}

variable "instance_ami_filters" {
  description = "Map used to find a suitable AMI (Amazon Linux 2 by default). You can override to choose a different AMI."
  type = map(string)
  default = {
    name_prefix = "amzn2-ami-hvm-*-x86_64-gp2"
    owner       = "amazon"
  }
}
