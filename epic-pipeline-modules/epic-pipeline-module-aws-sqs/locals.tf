locals {
  epic = {
    managed_by = "EPIC"
    team       = "CCoE"
    contract   = "pge-epic-module-v1"
  }

  base_name      = coalesce(var.custom_queue_name, "pge-epic-${var.app_name}-${var.environment}-${var.queue_name}")
  effective_name = var.fifo_queue ? "${local.base_name}.fifo" : local.base_name

  has_redrive_policy       = var.redrive_policy != null && length(trimspace(var.redrive_policy)) > 0
  has_redrive_allow_policy = var.redrive_allow_policy != null && length(trimspace(var.redrive_allow_policy)) > 0
  has_caller_queue_policy  = var.queue_policy_json != null && length(trimspace(var.queue_policy_json)) > 0

  data_classification    = try(var.tags["DataClassification"], "")
  is_high_classification = contains(["Confidential", "Restricted", "Privileged"], local.data_classification)

  effective_queue_policy = local.has_caller_queue_policy ? var.queue_policy_json : data.aws_iam_policy_document.saf_default[0].json
}
