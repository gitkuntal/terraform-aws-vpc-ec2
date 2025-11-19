aws_region        = "us-east-1"
allowed_ssh_cidr  = "0.0.0.0/0"   # <-- replace with YOUR public IPv4 /32 (do not use 0.0.0.0/0)
public_key_path   = "/.ssh/ec2_key2.pub" # <-- ensure this file exists and is your public key
instance_type     = "t3.micro"
