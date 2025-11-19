terraform {
  required_version = ">= 1.3, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Use a 6.x provider (current stable major as of Nov 2025)
      version = "~> 6.0"
    }
  }

  # Recommended to use a backend for real projects (s3 + dynamodb) — not required for local testing.
}
