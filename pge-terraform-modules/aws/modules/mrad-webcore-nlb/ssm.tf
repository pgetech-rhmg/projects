resource "aws_ssm_parameter" "active_neptune_cluster" {
  name        = "/webcore/${var.suffix}/active-neptune-cluster"
  description = "The active Neptune cluster for this branch"
  type        = "String"
  value       = "engage-neptune-${var.suffix}"
  tags        = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "readonly_nlb_arn" {
  name        = "/webcore/${var.suffix}/readonly-nlb-arn"
  description = "The read-only NLB ARN for this branch"
  type        = "String"
  value       = aws_lb.nlb_readonly.arn
  tags        = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "readwrite_nlb_arn" {
  name        = "/webcore/${var.suffix}/readwrite-nlb-arn"
  description = "The read-write NLB ARN for this branch"
  type        = "String"
  value       = aws_lb.nlb_readwrite.arn
  tags        = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}
