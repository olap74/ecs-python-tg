provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  required_providers {
    aws = {
      version = "~> 3.35"
    }
  }
}
