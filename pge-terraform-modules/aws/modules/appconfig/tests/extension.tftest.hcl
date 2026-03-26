run "extension" {
  command = apply

  module {
    source = "./examples/extension"
  }
}

variables {
  account_num                              = "750713712981"
  aws_region                               = "us-west-2"
  aws_role                                 = "CloudAdmin"
  name                                     = "ccoe-test-extension"
  description                              = "A very helpful description of this example extension."
  parameter_name                           = "ccoe-example-s3bucket"
  parameter_description                    = "ccoe-parameter-description"
  parameter_required                       = false
  action_name                              = "ccoe-example-PreCreateHostedConfigVersionForS3Backup"
  action_description                       = "A very helpful description of this action."
  action_point                             = "PRE_CREATE_HOSTED_CONFIGURATION_VERSION"
  action_role                              = "arn:aws:iam::750713712981:role/CCOE-AppConfig-Extension-Role"
  action_uri                               = "arn:aws:lambda:us-west-2:750713712981:function:MyS3ConfigurationBackUpExtension"
  enable_extension_association             = false
  resource_arn_to_associate_with_extension = null
}
