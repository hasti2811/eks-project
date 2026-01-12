output "eks_image" {
  value = data.aws_ecr_repository.eks_repo.repository_url
}