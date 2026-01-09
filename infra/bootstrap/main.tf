module "ecr" {
  source = "./modules/ecr"
  repo_name = var.repo_name
}

module "s3" {
  source = "./modules/s3"
  bucket_name = var.bucket_name
}

module "dynamodb" {
  source = "./modules/dynamodb"
  billing_mode = var.billing_mode
  dynamodb_name = var.dynamodb_name
  key = var.key
}
