resource "aws_dynamodb_table" "dynamodb-table-bounce" {
  name           = "SES_BOUNCES"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "recipientAddress"
  range_key      = "sesMessageId"
  attribute {
    name = "sesMessageId"
    type = "S"
  }
  attribute {
    name = "recipientAddress"
    type = "S"
  }
  attribute {
    name = "sesTimestamp"
    type = "N"
  }
  global_secondary_index {
    name            = "sesTimestamp-index"
    hash_key        = "sesTimestamp"
    write_capacity  = 5
    read_capacity   = 5
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "dynamodb-table-delivery" {
  name           = "SES_DELIVERIES"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "recipientAddress"
  range_key      = "sesMessageId"
  attribute {
    name = "sesMessageId"
    type = "S"
  }
  attribute {
    name = "recipientAddress"
    type = "S"
  }
  attribute {
    name = "sesTimestamp"
    type = "N"
  }
  global_secondary_index {
    name            = "sesTimestamp-index"
    hash_key        = "sesTimestamp"
    write_capacity  = 5
    read_capacity   = 5
    projection_type = "ALL"
  }
}
