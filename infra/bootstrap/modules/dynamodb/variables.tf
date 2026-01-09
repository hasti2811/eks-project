variable "dynamodb_name" {
  type = string
  description = "name for dynamodb for state locking"
}

variable "billing_mode" {
  type = string
  description = "billing mode for dynamodb"
}

variable "key" {
  type = string
  description = "hash key for dynamodb"
}