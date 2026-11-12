terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "sv-tfstate-prod-safouan"
    key          = "envs/prod/terraform.tfstate"
    region       = "eu-south-2"
    profile      = "sv-prod"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "eu-south-2"
  profile = "sv-prod"

  default_tags {
    tags = {
      Project     = "secure-vault"
      Environment = "prod"
      Owner       = "safouan"
      ManagedBy   = "terraform"
    }
  }
}