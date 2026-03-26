run "ssm-document" {
  command = apply

  module {
    source = "./examples/ssm-document"
  }
}

variables {
  account_num         = "750713712981"
  aws_region          = "us-west-2"
  aws_role            = "CloudAdmin"
  AppID               = "1001"
  Environment         = "Dev"
  DataClassification  = "Internal"
  CRIS                = "Low"
  Notify              = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner               = ["abc1", "def2", "ghi3"]
  Compliance          = ["None"]
  Order               = 8115205
  ssm_document_name   = "CCOE_patch_document_test_aicg"
  ssm_document_type   = "Automation"
  ssm_document_format = "JSON"
}
