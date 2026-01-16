# LB
# resource "aws_security_group" "lb_sg" {
#   name = "load balancer security group"
#   description = "security group for load balancer"
#   vpc_id = var.vpc_id

#   tags = {
#     Name = "security group for load balancer"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_http" {
#   security_group_id = aws_security_group.lb_sg.id
#   cidr_ipv4 = "0.0.0.0/0"
#   from_port = 80
#   ip_protocol = "tcp"
#   to_port = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_https" {
#   security_group_id = aws_security_group.lb_sg.id
#   cidr_ipv4 = "0.0.0.0/0"
#   from_port = 443
#   ip_protocol = "tcp"
#   to_port = 443
# }

# resource "aws_vpc_security_group_egress_rule" "lb_sg_egress" {
#   security_group_id = aws_security_group.lb_sg.id
#   cidr_ipv4 = "0.0.0.0/0"
#   ip_protocol = "-1"
# }

# EKS
# resource "aws_security_group" "eks-sg" {
#   name = "EKS security group"
#   description = "security group for EKS"
#   vpc_id = var.vpc_id

#   tags = {
#     Name = "security group for EKS"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "eks_sg_ingress_container_port" {
#   security_group_id = aws_security_group.eks-sg.id
#   # referenced_security_group_id = aws_security_group.lb_sg.id
#   from_port = 3000
#   ip_protocol = "tcp"
#   to_port = 3000
# }

# resource "aws_vpc_security_group_egress_rule" "eks_sg_egress" {
#   security_group_id = aws_security_group.eks-sg.id
#   cidr_ipv4 = "0.0.0.0/0"
#   ip_protocol = "-1"
# }


# node to node coms, cluster to node coms, http/https from 0.0.0.0/0 to ingress




# cluster SG

# resource "aws_security_group" "eks_cluster" {
#   name = "eks-cluster-sg"
#   description = "Security group for EKS control plane"
#   vpc_id      = var.vpc_id

#   tags = {
#     Name = "eks-cluster-sg"
#   }
# }




# node SG
resource "aws_security_group" "eks_nodes" {
  name        = "eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "eks-node-sg"
  }
}

# nodes accepting traffic from cluster SG
resource "aws_vpc_security_group_ingress_rule" "cluster_to_nodes_https" {
  security_group_id            = aws_security_group.eks_nodes.id
  referenced_security_group_id = var.eks_cluster_default_sg

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# kubelet accepting traffic from cluster SG on port 10250
resource "aws_vpc_security_group_ingress_rule" "cluster_to_kubelet" {
  security_group_id            = aws_security_group.eks_nodes.id
  referenced_security_group_id = var.eks_cluster_default_sg

  from_port   = 10250
  to_port     = 10250
  ip_protocol = "tcp"
}

# node to node traffic TCP
resource "aws_vpc_security_group_ingress_rule" "node_to_node_dns_tcp" {
  security_group_id = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.eks_nodes.id

  from_port   = 53
  to_port     = 53
  ip_protocol = "tcp"
}

# node to node traffic UDP
resource "aws_vpc_security_group_ingress_rule" "node_to_node_dns_ucp" {
  security_group_id = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.eks_nodes.id

  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"
}

# node egress
resource "aws_vpc_security_group_egress_rule" "nodes_egress_all" {
  security_group_id = aws_security_group.eks_nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
