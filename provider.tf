provider "aws" {
  # region can be passed via variable or environment AWS_REGION
  region = var.aws_region
    default_tags {
    tags = {
      ResourceGroup = var.resource_group
    }
  }
}
