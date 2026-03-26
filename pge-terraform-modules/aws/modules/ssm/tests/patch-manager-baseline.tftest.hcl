run "patch-manager-baseline" {
  command = apply

  module {
    source = "./examples/patch-manager-baseline"
  }
}

variables {
  account_num                       = "750713712981"
  aws_region                        = "us-west-2"
  aws_role                          = "CloudAdmin"
  AppID                             = "1001"
  Environment                       = "Dev"
  DataClassification                = "Internal"
  CRIS                              = "Low"
  Notify                            = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                             = ["abc1", "def2", "ghi3"]
  Compliance                        = ["None"]
  Order                             = 8115205
  ssm_patch_baseline_name           = "ssm_patch_baseline_aicg"
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
  patch_group_names = ["Dev"]
}
