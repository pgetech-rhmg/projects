run "tag-based-cross-region-copy-backup" {
  command = apply

  module {
    source = "./examples/tag-based-cross-region-copy-backup"
  }
}

variables {
  account_num                    = "750713712981"
  aws_region                     = "us-west-2"
  aws_role                       = "CloudAdmin"
  kms_role                       = "CloudAdmin"
  AppID                          = "1001"
  Environment                    = "Dev"
  DataClassification             = "Internal"
  CRIS                           = "Low"
  Notify                         = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                          = ["abc1", "def2", "ghi3"]
  Compliance                     = ["None"]
  Order                          = 8115205
  optional_tags                  = { pge_team = "ccoe-tf-developers" }
  vault_name                     = "vault-aurora-postgres"
  create_vault_notifications     = true
  backup_vault_events            = ["BACKUP_JOB_COMPLETED", "COPY_JOB_SUCCESSFUL", "COPY_JOB_FAILED"]
  replica_vault_name             = "replica-vault-aurora-postgres"
  aws_backup_plan_name           = "backup-plan-tag-based-postgres"
  backup_rule_name               = "backup-plan-rule-tag-based-postgres"
  backup_rule_schedule           = "cron(0 6 * * ? *)"
  backup_rule_start_window       = "60"
  backup_rule_completion_window  = "180"
  backup_rule_delete_after       = 3
  destination_vault_delete_after = 3
  backup_selection_name          = "selection-tag-based-postgres"
  aws_service                    = ["backup.amazonaws.com"]
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "application"
      value = "ccoe-postgres"
    },
    {
      type  = "STRINGEQUALS"
      key   = "component"
      value = "rds"
    }
  ]
  create_kms_key               = false
  existing_kms_key_arn         = "arn:aws:kms:us-west-2:750713712981:key/mrk-390793a8afd34ea9a41d4ce31b5b9341"
  existing_replica_kms_key_arn = "arn:aws:kms:us-east-1:750713712981:key/mrk-390793a8afd34ea9a41d4ce31b5b9341"
  snstopic_name                = "sns_aws_backup_example"
  snstopic_display_name        = "sns_aws_backup_example"
  endpoint                     = ["aicg@pge.com"]
  protocol                     = "email"
  sns_policy_file_name         = "sns_access_policy.json"
}
