run "role_with_customer_managed_policy" {
  command = apply

  module {
    source = "./examples/role_with_customer_managed_policy"
  }
}

variables {
  name               = "ccoe_terraform_role_customer_managed_policy"
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  aws_service        = ["ec2.amazonaws.com"]
  policy_name        = "ccoe_customerrole_managed_policy"
  path               = "/"
  description        = "policy creation for ccoe terrform test"
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
