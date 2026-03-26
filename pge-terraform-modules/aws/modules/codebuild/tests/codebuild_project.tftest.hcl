run "codebuild_project" {
  command = apply

  module {
    source = "./examples/codebuild_project"
  }
}

variables {
  account_num                   = "750713712981"
  aws_region                    = "us-west-2"
  aws_role                      = "CloudAdmin"
  kms_role                      = "CloudAdmin"
  kms_name                      = "codebuild_key"
  kms_description               = "kms key for codebuild"
  AppID                         = "1001"
  Environment                   = "Dev"
  DataClassification            = "Internal"
  CRIS                          = "Low"
  Notify                        = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                         = ["abc1", "def2", "ghi3"]
  Compliance                    = ["None"]
  Order                         = 8115205
  codebuild_project_name        = "codebuild_project_test_ccoe-6902"
  codebuild_project_description = "sample codebuild_project"
  concurrent_build_limit        = 1
  artifact_type                 = "NO_ARTIFACTS"
  cache_type                    = "S3"
  compute_type                  = "BUILD_GENERAL1_SMALL"
  environment_image             = "aws/codebuild/standard:1.0"
  environment_type              = "LINUX_CONTAINER"
  image_pull_credentials_type   = "CODEBUILD"
  cloudwatch_logs_group_name    = "logs-group"
  cloudwatch_logs_stream_name   = "logs-stream"
  s3_logs_status                = "ENABLED"
  source_git_clone_depth        = 1
  source_type                   = "GITHUB_ENTERPRISE"
  source_location               = "https://github.com/pgetech/test-codebuild-repo"
  source_fetch_sub              = true
  policy_file_name              = "policy.json"
  sg_name                       = "sg_cb_project_aicg"
  sg_description                = "security group for codebuild project"
  cidr_egress_rules = [{
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  secretsmanager_github_token_secret_name = "arn:aws:secretsmanager:us-west-2:750713712981:secret:github_token_stco-JMu81a"
  role_name                               = "cbproject_iam_role_aicg"
  role_service                            = ["codebuild.amazonaws.com"]
  bucket_name                             = "mybucket143mmtest"
  github_repository                       = "test-codebuild-repo"
  github_events                           = ["push"]
  github_content_type                     = "json"
  github_base_url                         = "https://api.github.com/"
}
