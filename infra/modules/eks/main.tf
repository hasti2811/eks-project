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
    public_access_cidrs = var.my_ip # ALLOW ACCESS FROM INTERNET ONLY FROM THIS IP
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
    desired_size = 2
    max_size     = 3
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

# resource "aws_eks_addon" "pod_identity" {
#   cluster_name = aws_eks_cluster.example.name
#   addon_name   = "eks-pod-identity-agent"
# }

# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name = aws_eks_cluster.example.name
#   addon_name   = "aws-ebs-csi-driver"
# }

# resource "aws_eks_addon" "cloudwatch_agent" {
#   cluster_name = aws_eks_cluster.example.name
#   addon_name   = "cloudwatch-agent"
# }
