run "iam_service_linked_roles" {
  command = apply

  module {
    source = "./examples/iam_service_linked_roles"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  aws_service_names  = ["lex.amazonaws.com", "continuousexport.discovery.amazonaws.com"]
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
  }
}
