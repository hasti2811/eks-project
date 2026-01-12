# LB
resource "aws_security_group" "lb_sg" {
  name = "load balancer security group"
  description = "security group for load balancer"
  vpc_id = var.vpc_id

  tags = {
    Name = "security group for load balancer"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_http" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_https" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  ip_protocol = "tcp"
  to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "lb_sg_egress" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# EKS
resource "aws_security_group" "eks-sg" {
  name = "EKS security group"
  description = "security group for EKS"
  vpc_id = var.vpc_id

  tags = {
    Name = "security group for EKS"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_sg_ingress_container_port" {
  security_group_id = aws_security_group.eks-sg.id
  referenced_security_group_id = aws_security_group.lb_sg.id
  from_port = 3000
  ip_protocol = "tcp"
  to_port = 3000
}

resource "aws_vpc_security_group_egress_rule" "eks_sg_egress" {
  security_group_id = aws_security_group.eks-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}