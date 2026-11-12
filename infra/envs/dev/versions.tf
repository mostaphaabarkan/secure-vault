terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "sv-tfstate-dev-safouan"
    key          = "envs/dev/terraform.tfstate"
    region       = "eu-south-2"
    profile      = "sv-dev"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "eu-south-2"
  profile = "sv-dev"

  default_tags {
    tags = {
      Project     = "secure-vault"
      Environment = "dev"
      Owner       = "safouan"
      ManagedBy   = "terraform"
    }
  }
}