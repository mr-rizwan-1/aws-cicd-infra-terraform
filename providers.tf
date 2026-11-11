terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "aws-cicd-infra-terraform" # bucket name
    key          = "cicd-infra/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # S3 native state locking
  }
}

provider "aws" {
  region = var.region
}