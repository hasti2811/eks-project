terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = " ~> 6.28.0"
    }
  }

  backend "s3" {
    bucket = "hasti-eks-project-bucket"
    key = "terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "dynamo-db-state-locking-eks"
    encrypt = true
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