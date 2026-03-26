run "conditions-based-resource-selection" {
  command = apply

  module {
    source = "./examples/conditions-based-resource-selection"
  }
}

variables {
  account_num          = "750713712981"
  aws_region           = "us-west-2"
  aws_role             = "CloudAdmin"
  kms_role             = "CloudAdmin"
  AppID                = "1001"
  Environment          = "Dev"
  DataClassification   = "Internal"
  CRIS                 = "Low"
  Notify               = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                = ["abc1", "def2", "ghi3"]
  Compliance           = ["None"]
  Order                = 8115205
  vault_name           = "vault-DB-apps"
  aws_backup_plan_name = "backup-plan-condition-based"
  aws_backup_plan_rule = [
    {
      rule_name         = "backup-plan-rule-condition-based"
      target_vault_name = "vault-DB-apps"
      schedule          = "cron(0 12 * * ? *)"
      lifecycle = {
        delete_after = 2
      }
  }]
  backup_selection_name = "backup-selection-condition-based"
  aws_service           = ["backup.amazonaws.com"]
}
