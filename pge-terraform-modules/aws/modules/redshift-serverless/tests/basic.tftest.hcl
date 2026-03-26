# Redshift Serverless Basic Test

run "basic" {
  command = apply

  module {
    source = "./examples/basic"
  }

  variables {
    account_num              = "750713712981"
    aws_region               = "us-west-2"
    aws_role                 = "CloudAdmin"
    kms_role                 = "TF_Developers"
    AppID                    = 1001
    Environment              = "Dev"
    DataClassification       = "Internal"
    CRIS                     = "Low"
    Notify                   = ["mzrk@pge.com", "r0k6@pge.com", "s7aw@pge.com"]
    Owner                    = ["mzrk", "r0k6", "s7aw"]
    Compliance               = ["None"]
    Order                    = 8115205
    optional_tags            = {}
    ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
    ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
    ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
    parameter_vpc_id_name    = "/vpc/id"
    name                     = "ccoe-test-redshift-serverless"
    admin_username           = "admin"
    db_name                  = "dev"
    base_capacity            = 128
    max_capacity             = 256
    log_exports              = ["userlog", "connectionlog"]
    enhanced_vpc_routing     = false
  }
}
