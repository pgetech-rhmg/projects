run "codepipeline_s3web_custom" {
  command = apply

  module {
    source = "./examples/codepipeline_s3web_custom"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  optional_tags = {
    Name     = "test"
    pge_team = "ccoe-tf-developers"
  }
  codepipeline_name                       = "codepipeline_s3static_web"
  repo_name                               = "s3-static-web-angular"
  artifact_bucket_owner_access            = "FULL"
  artifact_path                           = "codepipeline-new/"
  bucket_name                             = "codepipeline-bucket-s3static-web-stco"
  secretsmanager_github_token_secret_name = "github_token_m7k3:pat"
  ssm_parameter_vpc_id                    = "/vpc/id"
  ssm_parameter_subnet_id1                = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3                = "/vpc/2/privatesubnet3/id"
  ssm_parameter_artifactory_host          = "/jfrog/host"
  ssm_parameter_sonar_host                = "/sonarqube/host"
  ssm_parameter_artifactory_repo_key      = "/jfrog/artifactory/ccoe_npm_repo_key"
  secretsmanager_artifactory_token        = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user         = "jfrog_credentials:jfrog_user"
  secretsmanager_sonar_token              = "sonarqube_credentials:sonar_token"
  github_branch                           = "main"
  project_name                            = "s3-static-web"
  project_key                             = "s3-static-web"
  project_unit_test_dir                   = "provide-project-unit-test-dir-here"
  project_root_directory                  = "."
  artifact_name_nodejs                    = "provide-artifact-name-s3static-web"
  artifactory_key_path                    = "provide-artifactory-key-path-here"
  artifactory_upload_file                 = "provide-artifactory-upload-file-here"
  nodejs_version                          = "16"
  github_repo_url                         = "https://github.com/pgetech/s3-static-web-angular.git"
  codebuild_role_service                  = ["codebuild.amazonaws.com"]
  codepipeline_role_service               = ["codepipeline.amazonaws.com"]
  environment_image_codebuild             = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codebuild              = "LINUX_CONTAINER"
  source_location_codebuild               = "https://github.com/pgetech/s3-static-web-angular.git"
  concurrent_build_limit_codebuild        = 1
  compute_type_codebuild                  = "BUILD_GENERAL1_SMALL"
  environment_image_codescan              = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codescan               = "LINUX_CONTAINER"
  concurrent_build_limit_codescan         = 1
  compute_type_codescan                   = "BUILD_GENERAL1_SMALL"
  environment_image_codepublish           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codepublish            = "LINUX_CONTAINER"
  concurrent_build_limit_codepublish      = 1
  compute_type_codepublish                = "BUILD_GENERAL1_SMALL"
  sg_name                                 = "sg_codebuild_project_s3static_web"
  sg_description                          = "security group for codebuild project s3static_web"
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  s3_static_web_bucket_name      = "dev2-s3-static-web"
  s3_static_web_bucket_region    = "us-east-1"
  aws_cloudfront_distribution_id = "EMAKDCNP0MK48"
}
