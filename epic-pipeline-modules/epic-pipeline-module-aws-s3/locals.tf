locals {
  epic = {
      managed_by  = "EPIC"
      team        = "CCoE"
      contract    = "pge-epic-module-v1"
  }

  use_kms               = var.sse_algorithm == "aws:kms"
  has_bucket_policy     = var.bucket_policy_json != null && length(trimspace(var.bucket_policy_json)) > 0
  effective_bucket_name = coalesce(
    var.custom_bucket_name,
    "pge-epic-${var.app_name}-${var.environment}"
  )
}