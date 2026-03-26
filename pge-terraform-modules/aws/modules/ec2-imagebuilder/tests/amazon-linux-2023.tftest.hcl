run "amazon-linux-2023" {
  command = apply

  module {
    source = "./examples/amazon-linux-2023"
  }
}

variables {
  AppID                            = "1001"
  Environment                      = "Dev"
  DataClassification               = "Internal"
  CRIS                             = "Medium"
  Notify                           = ["v3cb@pge.com"]
  Owner                            = ["v3cb", "a2vb", "s81m"]
  Compliance                       = ["None"]
  name                             = "ccoe-al2023-imagebuilder"
  build_version                    = "1.0.0"
  test_version                     = "1.0.0"
  aws_region                       = "us-west-2"
  parent_image_ssm_path            = "ami-0a897ba00eaed7398"
  vpc_id                           = "/vpc/id"
  account_num                      = "750713712981"
  aws_role                         = "CloudAdmin"
  delete_on_termination_img_recipe = true
  pipeline_status                  = "ENABLED"
  platform                         = "Linux"
  ami_name                         = "ccoe-al2023-ami"
  vpc_cidr                         = "/vpc/cidr"
  force_destroy_s3_bucket          = true
  log_policy                       = "s3_log_policy.json"
  bucket_name                      = "imagebuilder-logs-s3-bucket"
  notification_email               = ["v3cb@pge.com"]
  launch_permission_user_ids       = []
  receipients                      = ["v3cb@pge.com"]
  sender                           = "v3cb@pge.com"
  target_accounts_table            = "abc"
}
