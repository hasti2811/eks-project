variable "public_subnet_ids" {
    description = "public subnet IDs"
    type = list(string)
}

variable "private_subnet_ids" {
    description = "private subnet IDs"
    type = list(string)
}

# variable "my_ip" {
#     description = "my IP address"
#     type = string
# }

variable "ami" {
  description = "ami"
  type = string
}

variable "instance_type" {
  description = "instance type"
  type = list(string)
}

variable "vpc_id" {
  
}