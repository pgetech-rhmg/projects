run "cross_account_role_policies" {
  command = apply

  module {
    source = "./examples/cross_account_role_policies"
  }
}

variables {
  name                   = "ccoe_terraform_cross_account_role"
  account_num            = "750713712981"
  aws_region             = "us-west-2"
  aws_role               = "CloudAdmin"
  policy_arns_list       = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  trusted_aws_principals = ["arn:aws:iam::056672152820:role/TFCBProvisioningRole", "arn:aws:iam::056672152820:role/CloudAdmin"]
  policy_name            = "ccoe_terraform_policy_test"
  path                   = "/"
  description            = "policy creation for ccoe terraform test"
  AppID                  = "1001"
  Environment            = "Dev"
  DataClassification     = "Internal"
  CRIS                   = "Low"
  Notify                 = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                  = ["abc1", "def2", "ghi3"]
  Compliance             = ["None"]
  Order                  = 8115205
  optional_tags = {
  }
}
