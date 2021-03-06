resource "aws_dynamodb_table" "pricewatch_titles" {
  name           = "pricewatch_titles"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "ASIN"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "ASIN"
    type = "S"
  }
}

resource "aws_dynamodb_table" "pricewatch_authors" {
  name           = "pricewatch_authors"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "AuthorName"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "AuthorName"
    type = "S"
  }
}

