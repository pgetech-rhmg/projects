run "codebuild_report" {
  command = apply

  module {
    source = "./examples/codebuild_report"
  }
}

variables {
  account_num                 = "750713712981"
  aws_region                  = "us-west-2"
  aws_role                    = "CloudAdmin"
  kms_role                    = "CloudAdmin"
  AppID                       = "1001"
  Environment                 = "Dev"
  DataClassification          = "Internal"
  CRIS                        = "Low"
  Notify                      = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                       = ["abc1", "def2", "ghi3"]
  Compliance                  = ["None"]
  kms_name                    = "codebuild_report_cmk"
  kms_description             = "cmk for codebuild report"
  bucket_name                 = "codebuild-report-test-bucket"
  codebuild_rg_name           = "test-report"
  codebuild_rg_type           = "TEST"
  codebuild_rg_delete_reports = true
  codebuild_rg_export_type    = "S3"
  codebuild_rg_packaging      = "NONE"
  codebuild_rg_path           = "/home"
  policy_file_name            = "policy.json"
}
