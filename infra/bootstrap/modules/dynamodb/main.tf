resource "aws_dynamodb_table" "my_dynamodb_table" {
  name = var.dynamodb_name
  billing_mode = var.billing_mode
  hash_key = var.key

  attribute {
    name = var.key
    type = "S"
  }

  tags = {
    Name = "DynamoDB for statelocking for EKS project"
  }
}
