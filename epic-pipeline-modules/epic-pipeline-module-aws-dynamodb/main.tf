resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  dynamic "attribute" {
    for_each = var.range_key != null ? [1] : []
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  dynamic "attribute" {
    for_each = var.additional_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = try(global_secondary_index.value.range_key, null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [1] : []
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  deletion_protection_enabled = var.deletion_protection_enabled

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  tags = var.tags
}
