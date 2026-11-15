resource "aws_dynamodb_table" "files" {
  name         = "sv-files-${local.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "owner_id"
  range_key    = "file_id"

  attribute {
    name = "owner_id"
    type = "S"
  }

  attribute {
    name = "file_id"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.uploads.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  deletion_protection_enabled = local.deletion_protection
}

output "files_table_name" {
  value = aws_dynamodb_table.files.name
}