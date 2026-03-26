/*
 * # AWS S3 module
 * Terraform module which creates SAF2.0 S3 in AWS
*/
#
# Filename    : modules/s3/main.tf
# Date        : 27 December 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : s3 creation module 


terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  versioning      = var.versioning
  principal_orgid = "o-7vgpdbu22o"
  namespace       = "ccoe-tf-developers"
  acl_grants = var.grants == null ? [] : flatten(
    [
      for g in var.grants : [
        for p in g.permissions : {
          id         = g.id
          type       = g.type
          permission = p
          uri        = g.uri
        }
      ]
  ])
  sse_algorithm = var.kms_key_arn == null ? "AES256" : "aws:kms"
}



locals {
  is_static_web            = (try(var.tags.BucketType, null) == "StaticWeb" || try(var.tags.BucketType, null) == "s3web") ? true : false
  is_dc_public_or_internal = (var.tags["DataClassification"] == "Internal" || var.tags["DataClassification"] == "Public") ? true : false

}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

data "external" "validate_kms" {
  count   = (!local.is_dc_public_or_internal && var.kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key arn is mandatory for the DataClassfication type; exit 1"]
}

data "external" "validate_staticweb" {
  count   = (!local.is_dc_public_or_internal && local.is_static_web) ? 1 : 0
  program = ["sh", "-c", ">&2 echo BucketType StaticWeb is not allowed for the DataClassfication type; exit 1"]
}


# Provides a S3 bucket resource.
resource "aws_s3_bucket" "default" {
  bucket              = var.bucket_name
  force_destroy       = var.force_destroy
  tags                = local.module_tags
  object_lock_enabled = var.object_lock_configuration != null ? true : false
}

# Provides a resource for controlling versioning on an S3 bucket
resource "aws_s3_bucket_versioning" "default" {
  bucket                = aws_s3_bucket.default.id
  expected_bucket_owner = var.expected_bucket_owner
  versioning_configuration {
    status = local.versioning
  }
}



# Provides an S3 bucket (server access) logging resource. 
resource "aws_s3_bucket_logging" "default" {
  count         = var.target_bucket != null ? 1 : 0
  bucket        = aws_s3_bucket.default.id
  target_bucket = var.target_bucket
  target_prefix = var.target_prefix
}

# Provides a S3 bucket server-side encryption configuration resource.
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket                = aws_s3_bucket.default.bucket
  expected_bucket_owner = var.expected_bucket_owner
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = local.sse_algorithm
    }
  }
}

#provides an s3 bucket object ownership.
resource "aws_s3_bucket_ownership_controls" "default" {
  bucket = aws_s3_bucket.default.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Provides an S3 bucket ACL resource.
resource "aws_s3_bucket_acl" "default" {
  depends_on            = [aws_s3_bucket_ownership_controls.default]
  bucket                = aws_s3_bucket.default.id
  expected_bucket_owner = var.expected_bucket_owner
  # Conflicts with access_control_policy so this is enabled if no grants
  acl = try(length(local.acl_grants), 0) == 0 ? var.acl : null
  dynamic "access_control_policy" {
    for_each = try(length(local.acl_grants), 0) == 0 || try(length(var.acl), 0) > 0 ? [] : [1]
    content {
      dynamic "grant" {
        for_each = local.acl_grants
        content {
          grantee {
            id   = grant.value.id
            type = grant.value.type
            uri  = grant.value.uri
          }
          permission = grant.value.permission
        }
      }
      owner {
        id           = var.owner["id"]
        display_name = try(var.owner["display_name"], null)
      }
    }
  }
}

# Provides an S3 bucket Object Lock configuration resource. 
# Thus, to enable Object Lock for a new bucket, see the Using object lock configuration resource given below. 
# If you want to enable Object Lock for an existing bucket, contact AWS Support
resource "aws_s3_bucket_object_lock_configuration" "default" {
  count                 = var.object_lock_configuration != null ? 1 : 0
  bucket                = aws_s3_bucket.default.id
  expected_bucket_owner = var.expected_bucket_owner
  rule {
    default_retention {
      mode  = var.object_lock_configuration.mode
      days  = var.object_lock_configuration.days
      years = var.object_lock_configuration.years
    }
  }
}

# Provides an S3 bucket CORS configuration resource
resource "aws_s3_bucket_cors_configuration" "default" {
  count                 = var.cors_rule_inputs != null ? 1 : 0
  bucket                = aws_s3_bucket.default.id
  expected_bucket_owner = var.expected_bucket_owner
  dynamic "cors_rule" {
    for_each = var.cors_rule_inputs
    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      id              = cors_rule.value.id
      allowed_headers = cors_rule.value.allowed_headers
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}





# Combines the user_defined_policy with the pge_compliance_kms_policy
data "aws_iam_policy_document" "combined" {
  source_policy_documents = [
    templatefile("${path.module}/s3_bucket_policy.json",
      {
        bucket_name     = var.bucket_name
        principal_orgid = local.principal_orgid
    }, ),
    var.policy
  ]
}



# Managed S3 bucket policy
resource "aws_s3_bucket_policy" "default" {
  count      = local.is_static_web ? 0 : 1
  bucket     = aws_s3_bucket.default.id
  policy     = data.aws_iam_policy_document.combined.json
  depends_on = [aws_s3_bucket_public_access_block.default]
}

# Manages S3 bucket-level Public Access Block configuration.
resource "aws_s3_bucket_public_access_block" "default" {
  bucket                  = aws_s3_bucket.default.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Provides an S3 bucket request payment configuration resource
resource "aws_s3_bucket_request_payment_configuration" "default" {
  count                 = var.request_payer != null ? 1 : 0
  bucket                = aws_s3_bucket.default.id
  expected_bucket_owner = var.expected_bucket_owner
  # Valid values: "BucketOwner" or "Requester"
  payer = lower(var.request_payer) == "requester" ? "Requester" : "BucketOwner"
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "default" {
  bucket = aws_s3_bucket.default.id
  name   = var.intelligent_tiering_name

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = var.archive_days
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = var.deeparchive_days
  }
}

