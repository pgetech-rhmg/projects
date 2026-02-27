locals {
  tags = {
    ManagedBy           = "EPIC"
    Team                = "CCoE"
    AWSAccountID        = var.aws_account_id
    AppID               = "APP-${var.appid}"
    Environment         = var.environment
    DataClassification  = var.dataclassification
    CRIS                = var.cris
    Notify              = join("_", var.notify)
    Owner               = join("_", var.owner)
    Compliance          = join("_", var.compliance)
    Order               = var.order
  }
}