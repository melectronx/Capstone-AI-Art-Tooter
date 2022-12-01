resource "aws_dynamodb_table" "toots" {
  name     = "toots"
  hash_key = "id"
  #range_key = "date"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "id"
    type = "N"
  }
  attribute {
    name = "date"
    type = "S"
  }
}
