# CLUSTER
resource "aws_eks_cluster" "example" {
  name = "example"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.34"

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = [ 
    "api",
    "audit",
    "authenticator"
   ]

  vpc_config {
    subnet_ids = var.public_subnet_ids # SUBNETS HERE HAS TO BE PUBLIC BECAUSE IT IS THE CLUSTER, NODES GO IN PRIVATE SUBNETS
    endpoint_private_access = true # ALLOWS ACCESS FROM WITHIN THE VPC
    endpoint_public_access = true # ALLOWS ACCESS FROM INTERNET (only specific IP's, check comment below)
    public_access_cidrs = ["${var.my_ip}/32"] # ALLOW ACCESS FROM INTERNET ONLY FROM THIS IP
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Name = "EKS cluster"
  }
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# NODE GROUPS
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.example.arn
  subnet_ids      = var.private_subnet_ids

  ami_type = var.ami
  instance_types = var.instance_type

  # remote_access {
  #   ec2_ssh_key = 
  #   source_security_group_ids = 
  # }

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "example" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example.name
}

# # ADDONS
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "eks-pod-identity-agent"
}

# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name = aws_eks_cluster.example.name
#   addon_name   = "aws-ebs-csi-driver"
# }

# resource "aws_eks_addon" "cloudwatch_agent" {
#   cluster_name = aws_eks_cluster.example.name
#   addon_name   = "cloudwatch-agent"
# }


# AWS LOAD BALANCER CONTROLLER IAM ROLE + POLICY + POD IDENTITY ASSOC
# resource "aws_iam_role" "alb_controller" {
#   name = "eks-alb-controller-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "pods.eks.amazonaws.com"
#       }
#       Action = [
#           "sts:AssumeRole",
#           "sts:TagSession"
#         ]
#     }]
#   })
# }

# resource "aws_iam_policy" "alb_controller" {
#   name = "AWSLoadBalancerControllerIAMPolicy"
#   policy = file("${path.module}/iam_policy.json")
# }

# resource "aws_iam_role_policy_attachment" "alb_controller" {
#   role = aws_iam_role.alb_controller.name
#   policy_arn = aws_iam_policy.alb_controller.arn
# }

# resource "kubernetes_service_account_v1" "alb_controller" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/component" = "controller"
#       "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#     }
#   }
# }

# resource "aws_eks_pod_identity_association" "alb" {
#   cluster_name    = aws_eks_cluster.example.name
#   namespace       = "kube-system"
#   service_account = "aws-load-balancer-controller"
#   role_arn        = aws_iam_role.alb_controller.arn
# }

# # HELM RELEASE FOR AWS LOAD BALANCER CONTROLLER
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   version    = "1.7.2"

#   set = [
#     {
#       name  = "serviceAccount.create"
#       value = "false"
#     },
#     {
#       name  = "serviceAccount.name"
#       value = "aws-load-balancer-controller"
#     },
#     {
#       name  = "clusterName"
#       value = aws_eks_cluster.example.name
#     },
#     {
#       name  = "region"
#       value = "eu-west-2"
#     },
#     {
#     name  = "vpcId"
#     value = var.vpc_id
#     }
#   ]

#   depends_on = [aws_iam_role_policy_attachment.alb_controller]
# }

# # IAM FOR EXTERNAL DNS

# resource "aws_iam_role" "external_dns" {
#   name = "eks-external-dns-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "pods.eks.amazonaws.com"
#         }
#         Action = [
#           "sts:AssumeRole",
#           "sts:TagSession"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "external_dns" {
#   name   = "ExternalDNSPolicy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "route53:ChangeResourceRecordSets"
#         ]
#         Resource = [
#           "arn:aws:route53:::hostedzone/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "route53:ListHostedZones",
#           "route53:ListResourceRecordSets",
#           "route53:ListTagsForResource"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "external_dns" {
#   role       = aws_iam_role.external_dns.name
#   policy_arn = aws_iam_policy.external_dns.arn
# }

# resource "kubernetes_service_account_v1" "external_dns" {
#   metadata {
#     name      = "external-dns"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name"      = "external-dns"
#     }
#   }
# }

# resource "aws_eks_pod_identity_association" "external_dns" {
#   cluster_name    = aws_eks_cluster.example.name
#   namespace       = "kube-system"
#   service_account = "external-dns" 
#   role_arn        = aws_iam_role.external_dns.arn
# }

# # Helm release for ExternalDNS
# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   namespace  = "kube-system"
#   repository = "https://kubernetes-sigs.github.io/external-dns"
#   chart      = "external-dns"
#   version    = "1.19.0" 

#   set = [
#     {
#       name  = "provider"
#       value = "aws"
#     },
#     # {
#     #   name  = "aws.zoneType"
#     #   value = "public"
#     # },
#     {
#       name  = "serviceAccount.create"
#       value = "false"
#     },
#     {
#       name  = "serviceAccount.name"
#       value = "external-dns"
#     },
#     {
#       name  = "domainFilters[0]"
#       value = "hastiamin.co.uk" # only manage your domain
#     }
#     # {
#     #   name  = "policy"
#     #   value = "upsert-only"      # only create/update, don't delete
#     # },
#     # {
#     #   name  = "registry"
#     #   value = "txt"
#     # },
#     # {
#     #   name  = "txtOwnerId"
#     #   value = "external-dns"     # must be unique per cluster
#     # },
#     # {
#     # name  = "ingressClass"
#     # value = "alb"
#     # },
#     # {
#     # name  = "extraArgs[0]"
#     # value = "--ingress-class=alb"
#     # }

#   ]

#   depends_on = [
#     aws_eks_pod_identity_association.external_dns
#   ]
# }

# # CERT MANAGER IAM

# resource "aws_iam_policy" "cert_manager_route53" {
#   name = "CertManagerRoute53Policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "route53:GetChange"
#         ]
#         Resource = "arn:aws:route53:::change/*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "route53:ChangeResourceRecordSets",
#           "route53:ListResourceRecordSets"
#         ]
#         Resource = "arn:aws:route53:::hostedzone/*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "route53:ListHostedZones"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role" "cert_manager" {
#   name = "eks-cert-manager-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "pods.eks.amazonaws.com"
#       }
#       Action = [
#         "sts:AssumeRole",
#         "sts:TagSession"
#       ]
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "cert_manager" {
#   role       = aws_iam_role.cert_manager.name
#   policy_arn = aws_iam_policy.cert_manager_route53.arn
# }

# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   namespace  = "cert-manager"

#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   version    = "v1.14.4"

#   create_namespace = true

#   set = [
#     {
#     name  = "installCRDs"
#     value = "true"
#     }
#   ]
# }

# # resource "kubernetes_service_account_v1" "cert_manager" {
# #   metadata {
# #     name      = "cert-manager"
# #     namespace = "cert-manager"
# #   }
# # }

# resource "aws_eks_pod_identity_association" "cert_manager" {
#   cluster_name    = aws_eks_cluster.example.name
#   namespace       = "cert-manager"
#   service_account = "cert-manager"
#   role_arn        = aws_iam_role.cert_manager.arn
# }
