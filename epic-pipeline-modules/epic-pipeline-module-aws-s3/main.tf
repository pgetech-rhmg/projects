resource "aws_s3_bucket" "this" {
  bucket        = local.effective_bucket_name
  force_destroy = var.force_destroy

  tags = var.tags

  lifecycle {
    precondition {
      condition     = local.effective_bucket_name != null && length(local.effective_bucket_name) > 0
      error_message = "Resolved bucket name must not be empty."
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.enable_public_access_block ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = local.use_kms ? var.kms_key_arn : null
    }

    bucket_key_enabled = local.use_kms
  }

  lifecycle {
    precondition {
      condition     = local.use_kms ? (var.kms_key_arn != null && length(var.kms_key_arn) > 0) : true
      error_message = "kms_key_arn must be provided when sse_algorithm is set to 'aws:kms'."
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.access_log_bucket
  target_prefix = var.access_log_prefix

  lifecycle {
    precondition {
      condition     = var.enable_access_logging ? (var.access_log_bucket != null && length(var.access_log_bucket) > 0) : true
      error_message = "access_log_bucket must be provided when enable_access_logging is true."
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = try([rule.value.filter], [])
        content {
          # Pass-through structure; caller must provide valid filter shape for AWS provider.
          # Common patterns: { prefix = "logs/" } or { and = { ... } }
          prefix = try(filter.value.prefix, null)

          dynamic "and" {
            for_each = try([filter.value.and], [])
            content {
              prefix = try(and.value.prefix, null)
              tags   = try(and.value.tags, null)
            }
          }
        }
      }

      dynamic "transition" {
        for_each = try(rule.value.transitions, [])
        content {
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = try([rule.value.expiration], [])
        content {
          days = try(expiration.value.days, null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try([rule.value.noncurrent_version_expiration], [])
        content {
          noncurrent_days = try(noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count   = local.has_bucket_policy ? 1 : 0
  bucket  = aws_s3_bucket.this.id
  policy  = var.bucket_policy_json
}

resource "aws_s3_object" "upload" {
  count = var.upload_object != null ? 1 : 0

  bucket = aws_s3_bucket.this.id
  key    = var.upload_object.key
  source = var.upload_object.source

  etag = filemd5(var.upload_object.source)

  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_server_side_encryption_configuration.this
  ]
}
