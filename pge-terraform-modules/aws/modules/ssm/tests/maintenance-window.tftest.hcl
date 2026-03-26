run "maintenance-window" {
  command = apply

  module {
    source = "./examples/maintenance-window"
  }
}

variables {
  account_num                                  = "750713712981"
  aws_region                                   = "us-west-2"
  aws_role                                     = "CloudAdmin"
  kms_role                                     = "CloudAdmin"
  AppID                                        = "1001"
  Environment                                  = "Dev"
  DataClassification                           = "Internal"
  CRIS                                         = "Low"
  Notify                                       = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                        = ["abc1", "def2", "ghi3"]
  Compliance                                   = ["None"]
  Order                                        = 8115205
  scan_maintenance_window_name                 = "PGE-ScanPatches-aicg"
  scan_maintenance_window_schedule             = "cron(0 0/4 * * ? *)"
  scan_maintenance_window_duration             = 3
  scan_maintenance_window_cutoff               = 1
  scan_maintenance_window_target_resource_type = "INSTANCE"
  scan_maintenance_windows_targets = [{
    key    = "tag:Patch Group"
    values = ["Dev"]
  }]
  scan_maintenance_window_task_name = "scan-task-run-command"
  scan_maintenance_window_task_type = "RUN_COMMAND"
  scan_maintenance_window_task_arn  = "AWS-RunPatchBaseline"
  scan_task_target_key              = "InstanceIds"
  scan_task_run_command_parameters = [
    {
      name   = "Operation"
      values = ["Scan"]
    },
    {
      name   = "RebootOption"
      values = ["NoReboot"]
    }
  ]
  scan_maintenance_window_task_max_concurrency = 2
  scan_maintenance_window_task_max_errors      = 1
  cloudwatch_output_enabled                    = true
  automation_maintenance_window_task_name      = "install-task-automation"
  automation_maintenance_window_task_type      = "AUTOMATION"
  automation_maintenance_window_task_arn       = "CCOE-Patch-Automation"
  automation_task_target_key                   = "InstanceIds"
  automation_maintenance_window_task_priority  = 5
  automation_task_invocation_automation_parameters = [
    {
      document_version = "$LATEST"
      auto_parameters = [
        {
          name   = "Operation"
          values = ["Install"]
        },
        {
          name   = "RebootOption"
          values = ["Reboot"]
        }
      ]
    }
  ]
  automation_maintenance_window_task_max_concurrency = 2
  automation_maintenance_window_task_max_errors      = 1
  lambda_maintenance_window_task_name                = "task-lambda"
  lambda_maintenance_window_task_type                = "LAMBDA"
  lambda_maintenance_window_task_arn                 = "arn:aws:lambda:us-west-2:750713712981:function:remoteip-test"
  lambda_maintenance_window_task_priority            = 10
  kms_key                                            = "pge-ssm-kms-aicg"
  kms_description                                    = "The description of the key as viewed in AWS console."
  bucket_name                                        = "ssm-patch-manager-s3-aicg"
  output_s3_key_prefix                               = "scan"
  sns_iam_name                                       = "sns_ssm_patch_manager_role"
  sns_iam_aws_service                                = ["ssm.amazonaws.com"]
  snstopic_name                                      = "sns_ssm_mw_ccoe_example"
  snstopic_display_name                              = "sns_ssm_mw_ccoe_example"
  endpoint                                           = ["aicg@pge.com"]
  protocol                                           = "email"
}
