locals {
  epic = {
      managed_by  = "EPIC"
      team        = "CCoE"
      contract    = "pge-epic-module-v1"
  }
  
  use_custom_cert = var.custom_acm_certificate_arn != null
}