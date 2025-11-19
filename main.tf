# --- Data: pick availability zone and an AMI (Amazon Linux 2) ---
data "aws_availability_zones" "available" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = [var.instance_ami_filters["owner"]]

  filter {
    name   = "name"
    values = [var.instance_ami_filters["name_prefix"]]
  }
}

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf-vpc-main"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "tf-igw"
  }
}

# --- Public Subnet ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tf-public-subnet"
  }
}

# --- Private Subnet ---
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "tf-private-subnet"
  }
}

# --- Public Route Table + Route to IGW ---
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tf-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# --- Security Group for SSH into public instance ---
resource "aws_security_group" "ssh_sg" {
  name        = "tf-ssh-sg"
  description = "Allow SSH from allowed CIDR"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from allowed CIDR"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [var.allowed_ssh_cidr]
    ipv6_cidr_blocks = []
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-ssh-sg"
  }
}

# --- Key pair from local public key ---
resource "aws_key_pair" "deployer" {
  key_name   = "tf-deployer-key"
  public_key = file(var.public_key_path)
}

# --- EC2 instance in public subnet ---
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  key_name               = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  tags = {
    Name = "tf-public-ec2"
  }

  # Simple user_data example (optional)
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from Terraform" > /home/ec2-user/hello.txt
              EOF
}
