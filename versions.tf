terraform {
  required_version = ">= 1.3, < 2.0"

  backend "s3" {
    # Replace these values BEFORE running `terraform init`
    bucket         = "terraform-aws-vpc-ec2-bucket"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
