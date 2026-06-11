data "aws_iam_policy_document" "saf_default" {
  count = local.has_caller_queue_policy ? 0 : 1

  statement {
    sid    = "AllowConsumerOverTls"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_principal_arns
    }

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
    ]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }

  statement {
    sid    = "DenyFromInternet"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["sqs:*"]
    resources = ["*"]

    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values   = var.internal_cidr_blocks
    }

    condition {
      test     = "Bool"
      variable = "aws:ViaAWSService"
      values   = ["false"]
    }
  }
}

resource "aws_sqs_queue" "this" {
  name = local.effective_name

  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_queue ? var.fifo_throughput_limit : null

  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null
  sqs_managed_sse_enabled           = var.kms_master_key_id == null ? var.sqs_managed_sse_enabled : null

  redrive_policy       = local.has_redrive_policy ? var.redrive_policy : null
  redrive_allow_policy = local.has_redrive_allow_policy ? var.redrive_allow_policy : null

  tags = var.tags

  lifecycle {
    precondition {
      condition = !(
        local.is_high_classification &&
        (var.kms_master_key_id == null || length(trimspace(var.kms_master_key_id)) == 0)
      )
      error_message = "kms_master_key_id (CMK) is mandatory per SAF Item #2 when DataClassification is Confidential, Restricted, or Privileged."
    }

    precondition {
      condition     = var.kms_master_key_id != null || var.sqs_managed_sse_enabled
      error_message = "Encryption at rest is required per SAF Item #1 — provide kms_master_key_id (CMK) or set sqs_managed_sse_enabled=true."
    }

    precondition {
      condition     = local.has_caller_queue_policy || length(var.allowed_principal_arns) > 0
      error_message = "Provide either queue_policy_json or allowed_principal_arns so the synthesized SAF default policy has a valid Allow statement."
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id
  policy    = local.effective_queue_policy
}
