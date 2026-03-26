run "state-manager-association" {
  command = apply

  module {
    source = "./examples/state-manager-association"
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
  Order                    = 8115205
  ssm_parameter_vpc_id     = "/vpc/id"
  ssm_parameter_subnet_id1 = "/vpc/privatesubnet2/id"
  kms_key                  = "pge-ssm-kms-rb1c"
  kms_description          = "The description of the key as viewed in AWS console."
  sns_iam_name             = "sns_ssm_patch_mgr_role_example"
  sns_iam_aws_service      = ["ssm.amazonaws.com"]
  snstopic_name            = "sns_ssm_mw_ccoe_test"
  snstopic_display_name    = "sns_ssm_mw_ccoe_examples"
  endpoint                 = ["sycz@pge.com"]
  protocol                 = "email"
  ssm_document_name        = "ccoe_patch_document_example1"
  ssm_document_type        = "Automation"
  ssm_document_format      = "JSON"
  document_iam_name        = "ccoe_remidiation_automation_doc_iam_role_example"
  document_iam_aws_service = ["ssm.amazonaws.com"]
  lambda_function_name     = "baseline-overrides"
  lambda_iam_name          = "ccoe-BaselineOverride-LambdaRole-example"
  ssm_association_name     = "ssm_association_test"
  schedule_expression      = "cron(0 0/12 * * ? *)"
  statemanager_s3_bucket   = "statemanger-output-s3-bkt-test"
  document_bucket_name     = "aws-quicksetup-patch-test"
  output_s3_key_prefix     = "logs/AutomationDocument"
  cidr_egress_rules_codebuild = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  ssm_patch_baseline_name           = "PGE-AmazonLinux2PatchBaseline-test"
  operating_system                  = "AMAZON_LINUX_2"
  set_default_patch_baseline        = false
  approved_patches_compliance_level = "HIGH"
  patch_baseline_approval_rules = [
    {
      approve_after_days  = 1
      compliance_level    = "HIGH"
      enable_non_security = true
      patch_baseline_filters = [
        {
          name   = "PRODUCT"
          values = ["AmazonLinux2", "AmazonLinux2.0"]
        },
        {
          name   = "CLASSIFICATION"
          values = ["Security", "Bugfix", "Recommended"]
        },
        {
          name   = "SEVERITY"
          values = ["Critical", "Important"]
        }
      ]
    },
    {
      approve_after_days  = 7
      compliance_level    = "MEDIUM"
      enable_non_security = false
      patch_baseline_filters = [
        {
          name   = "PRODUCT"
          values = ["AmazonLinux2", "AmazonLinux2.0"]
        },
        {
          name   = "CLASSIFICATION"
          values = ["Newpackage"]
        },
        {
          name   = "SEVERITY"
          values = ["Important"]
        }
      ]
    }
  ]
  patch_group_names           = ["test1"]
  aws_org_id                  = "o-3dot1zcpsr"
  apply_only_at_cron_interval = true
}
