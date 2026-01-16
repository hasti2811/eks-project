# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_network_address_usage_metrics = true

  tags = {
    Name = "VPC for EKS project"
  }
}

# IGW and RNATGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  
  tags = {
    Name = "igw for vpc"
  }
}

resource "aws_nat_gateway" "rnat" {
  vpc_id = aws_vpc.my_vpc.id
  availability_mode = "regional"
}

# AZ pool
data "aws_availability_zones" "azs" {
  state = "available"
}

# public subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  count = 3
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnets"
  }
}

# private subnets
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  count = 3
  map_public_ip_on_launch = false

  tags = {
    Name = "Private subnets"
  }
}

# public RTB
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public route table"
  }
}

# public RTB association
resource "aws_route_table_association" "public_rtb_assoc" {
  count = 3
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

# private RTB
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.rnat.id
  }

  tags = {
    Name = "private route table"
  }
}

# private RTB association
resource "aws_route_table_association" "private_rtb_assoc" {
  count = 3
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

# resource "aws_flow_log" "example" {
#   iam_role_arn    = aws_iam_role.iam_vpc_flow_logs_cw.arn
#   log_destination = aws_cloudwatch_log_group.vpc_flow_logs_cw_group.arn
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.my_vpc.id
# }

# resource "aws_cloudwatch_log_group" "vpc_flow_logs_cw_group" {
#   name = "vpc_flow_logs_cw"
# }

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["vpc-flow-logs.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "iam_vpc_flow_logs_cw" {
#   name               = "vpc_flow_logs_cloudwatch_role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# data "aws_iam_policy_document" "vpc_flow_logs_cw_policy_doc" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "example" {
#   name   = "example"
#   role   = aws_iam_role.iam_vpc_flow_logs_cw.id
#   policy = data.aws_iam_policy_document.vpc_flow_logs_cw_policy_doc.json
# }
