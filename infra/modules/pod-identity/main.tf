# IAM FOR EXTERNAL DNS

resource "aws_iam_role" "external_dns" {
  name = "eks-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "external_dns" {
  name   = "ExternalDNSPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

# resource "kubernetes_service_account_v1" "external_dns" {
#   metadata {
#     name      = "external-dns"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name"      = "external-dns"
#     }
#   }
# }

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = var.eks_cluster_name
  namespace       = "external-dns"
  service_account = "external-dns" 
  role_arn        = aws_iam_role.external_dns.arn
}