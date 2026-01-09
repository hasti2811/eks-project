variable "repo_name" {
  type = string
  description = "name for ECR repository"
  default = "eks-repo"
}

variable "bucket_name" {
  type = string
  description = "name of s3 bucket for state locking"
  default = "hasti-eks-project-bucket"
}

variable "dynamodb_name" {
  type = string
  description = "name for dynamodb for state locking"
  default = "dynamo-db-state-locking-eks"
}

variable "billing_mode" {
  type = string
  description = "billing mode for dynamodb"
  default = "PAY_PER_REQUEST"
}

variable "key" {
  type = string
  description = "hash key for dynamodb"
  default = "LockID"
}
