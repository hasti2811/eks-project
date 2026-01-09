terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = " ~> 6.28.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Environment = "main"
      Project = "EKS"
    }
  }
}