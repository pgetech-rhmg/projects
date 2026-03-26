run "cognito-identity-pool" {
  command = apply

  module {
    source = "./examples/cognito-identity-pool"
  }
}

variables {
  aws_region                   = "us-west-2"
  account_num                  = "750713712981"
  aws_role                     = "CloudAdmin"
  AppID                        = "1001"
  Environment                  = "Dev"
  DataClassification           = "Internal"
  CRIS                         = "Low"
  Notify                       = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                        = ["abc1", "def2", "ghi3"]
  Compliance                   = ["None"]
  Order                        = 8115205
  name                         = "Cognito_DefaultAuthenticatedRole"
  identity_pool_name           = "cognito-identity-pool-ccoe"
  allow_classic_flow           = false
  openid_connect_provider_arns = ["arn:aws:iam::750713712981:oidc-provider/itiampingdev.cloud.pge.com"]
}
