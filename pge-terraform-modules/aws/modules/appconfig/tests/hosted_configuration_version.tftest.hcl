run "hosted_configuration_version" {
  command = apply

  module {
    source = "./examples/hosted_configuration_version"
  }
}

variables {
  account_num              = "750713712981"
  aws_region               = "us-west-2"
  aws_role                 = "CloudAdmin"
  AppID                    = "1001"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["None"]
  description              = "A well thought out description of the hosted configuration version."
  content                  = "some content"
  application_id           = "3jcwgsa"
  configuration_profile_id = "7misyup"
}
