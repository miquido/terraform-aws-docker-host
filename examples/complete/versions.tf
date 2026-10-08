terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile # null = the default credential chain (AWS_PROFILE, SSO, instance role, ...)

  # Tags every resource with where it came from, so a stray one in the console can be traced back.
  default_tags {
    tags = {
      ManagedBy  = "terraform"
      Repository = "https://github.com/miquido/terraform-aws-docker-host"
      Example    = "examples/complete"
    }
  }
}
