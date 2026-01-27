variable "vpc_cidr" {
  type = string
  description = "CIDR block for VPC"
  default = "10.0.0.0/16"
}

variable "my_ip" {
  type = string
  description = "my IP address"
}

variable "ami" {
  description = "ami"
  type = string
  default = "AL2023_x86_64_STANDARD"
}

variable "instance_type" {
  description = "instance type"
  type = list(string)
  default = ["t3.medium"]
}
