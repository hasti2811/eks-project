output "eks_cluster_default_sg" {
  value = aws_eks_cluster.example.vpc_config[0].cluster_security_group_id
}

# index it to 0 to reference the only 1 cluster
