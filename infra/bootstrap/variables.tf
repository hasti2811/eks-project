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