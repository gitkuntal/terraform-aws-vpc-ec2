# 🚀 Terraform AWS VPC + EC2 Project

This project deploys a complete AWS networking setup using Terraform, including:

- **VPC** (`12.0.0.0/16`)
- **Public + Private Subnets**
- **Internet Gateway**
- **Route Table**
- **EC2 Instance (t3.micro)** with SSH access
- **Security Group allowing SSH from your IP**
- **S3 Remote Backend + DynamoDB State Locking**
- **Automatic Resource Group Tagging**

This README explains how to set up AWS CLI, Terraform, backend prerequisites, and how to run this project end-to-end on your local machine.

---

## 📁 Project Structure

```
terraform-aws-vpc-ec2/
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars
├── .gitignore
└── README.md
```

---

# 🧰 Prerequisites

You must have:

- An **AWS account**
- **AWS CLI installed** and configured
- **Terraform v1.3+**
- An **SSH key pair** (public key required)

---

# 📦 1. Install AWS CLI

### Windows
Download MSI installer:  
https://awscli.amazonaws.com/AWSCLIV2.msi

### macOS
```bash
brew install awscli
```

### Linux
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Verify installation
```bash
aws --version
```

---

# 🔐 2. Configure AWS Credentials

Run:
```bash
aws configure
```

Enter:

```
AWS Access Key ID: <your key>
AWS Secret Access Key: <your secret>
Default region name: us-east-1
Default output format: json
```

AWS stores these in:

```
~/.aws/credentials
~/.aws/config
```

---

# 📦 3. Install Terraform

### Windows
Download ZIP:  
https://releases.hashicorp.com/terraform/  
Extract → add `terraform.exe` to PATH.

### macOS
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Linux
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
sudo install -o root -g root -m 644 hashicorp.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list'
sudo apt update
sudo apt install terraform
```

### Verify
```bash
terraform -version
```

---

# ☁️ 4. Create S3 Backend + DynamoDB Table (One-Time Setup)

Terraform cannot create its own backend.  
Create them **manually once**:

Replace the bucket name with a globally unique name:

```bash
BUCKET="my-terraform-state-bucket-unique123"
REGION="us-east-1"
DDB_TABLE="tf-state-locks"

aws s3api create-bucket   --bucket "${BUCKET}"   --region "${REGION}"   --create-bucket-configuration LocationConstraint=${REGION}

aws s3api put-bucket-versioning   --bucket "${BUCKET}" --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption   --bucket "${BUCKET}"   --server-side-encryption-configuration '{"Rules":[
    {"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}
  ]}'

aws dynamodb create-table   --table-name "${DDB_TABLE}"   --attribute-definitions AttributeName=LockID,AttributeType=S   --key-schema AttributeName=LockID,KeyType=HASH   --billing-mode PAY_PER_REQUEST   --region "${REGION}"
```

Ensure your `versions.tf` uses the same bucket/table.

---

# ⚙️ 5. Configure terraform.tfvars

Edit `terraform.tfvars`:

```hcl
aws_region       = "us-east-1"
allowed_ssh_cidr = "YOUR_PUBLIC_IP/32"
public_key_path  = "~/.ssh/id_rsa.pub"
instance_type    = "t3.micro"
resource_group   = "terraform-demo"
```

Find your IP:

```bash
curl https://ifconfig.me
```

---

# 🚀 6. Initialize Terraform

```bash
terraform init
```

This downloads providers and configures the S3 backend.

---

# 📋 7. Review the Plan

```bash
terraform plan
```

---

# ▶️ 8. Apply the Infrastructure

```bash
terraform apply
```

Type **yes**.

Resources created:

- VPC  
- Subnets  
- IGW  
- Route Table  
- Security Group  
- Key Pair  
- EC2 instance  

---

# 🔑 9. SSH into EC2 Instance

Get instance IP:

```bash
terraform output ec2_public_ip
```

SSH in:

```bash
ssh -i ~/.ssh/id_rsa ec2-user@<public-ip>
```

For Ubuntu AMIs:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<public-ip>
```

---

# 🧹 10. Destroy Infrastructure

```bash
terraform destroy
```

Type **yes**.

---

# 🛠 Troubleshooting

### ❌ SSH timeout
Check:

- Security group allows your IP on port 22  
- Your IP didn't change  
- Instance has public IP  
- Route table has `0.0.0.0/0 → igw`  

### ❌ Backend not found
S3 bucket and DynamoDB table must exist before:

```bash
terraform init
```

### ❌ Permissions issue
Ensure your AWS credentials have:

- S3 full access (for backend bucket)
- DynamoDB write access (for locking)
- EC2/VPC permissions

### ❌ Key permission issue
```bash
chmod 600 ~/.ssh/id_rsa
```

---

# 🌟 Want to Extend This Project?

I can help you add:

- NAT Gateway + Private EC2  
- Application Load Balancer  
- RDS MySQL/Postgres  
- SSM Session Manager (SSH-less access)  
- Autoscaling groups  
- EKS / ECS  
- Multi-env structure (dev/test/prod folders)

Just tell me!

---

# 👍 You're Ready!

Your Terraform project is now fully documented and ready for GitHub or team use.
