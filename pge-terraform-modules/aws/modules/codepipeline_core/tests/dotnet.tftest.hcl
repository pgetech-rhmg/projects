run "dotnet" {
  command = apply

  module {
    source = "./examples/dotnet"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  optional_tags = {
    Name     = "test"
    pge_team = "ccoe-tf-developers"
  }
  codepipeline_name                       = "codepipeline-dotnet-stco"
  github_org                              = "pgetech"
  repo_name                               = "test_codepipeline_dotnet"
  branch                                  = "main"
  metadata_http_endpoint                  = "enabled"
  artifact_bucket_owner_access            = "FULL"
  artifact_path                           = "codepipeline-new/"
  bucket_name                             = "codepipeline-bucket-dotnet"
  secretsmanager_github_token_secret_name = "github_token_r5vd:pat"
  secretsmanager_artifactory_token        = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user         = "jfrog_credentials:jfrog_user"
  secretsmanager_sonar_token              = "sonarqube_credentials:sonar_token"
  ssm_parameter_vpc_id                    = "/vpc/id"
  ssm_parameter_subnet_id1                = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3                = "/vpc/2/privatesubnet3/id"
  ssm_parameter_artifactory_host          = "/jfrog/host"
  ssm_parameter_artifactory_repo_key      = "/jfrog/nuget/artifactory"
  ssm_parameter_sonar_host                = "/sonarqube/host"
  artifact_version                        = "1.0"
  project_name                            = "sample-dotnet-ccoe-1121"
  project_key                             = "sample-dotnet-ccoe-1121"
  project_root_directory                  = "quickstart-dotnetcore-cicd"
  dotnet_version                          = "6.0"
  github_branch                           = "main"
  project_unit_test_dir                   = ""
  unit_test_commands                      = "dotnet test $PROJECT_UNIT_TEST_DIRECTORY -c release --logger trx --results-directory ./testresults"
  project_file_location                   = "WebApplicationSample"
  artifact_name_dotnet                    = "sample-dotnet-ccoe-4161.zip"
  github_repo_url                         = "https://github.com/pgetech/test_codepipeline_dotnet.git"
  codebuild_role_service                  = ["codebuild.amazonaws.com"]
  codetest_role_name                      = "codetest_dotnet_iam_policy"
  codepipeline_role_service               = ["codepipeline.amazonaws.com"]
  custom_codebuild_policy_file            = "custom_codebuild_file.json"
  custom_codescan_policy_file             = "custom_codescan_file.json"
  custom_codepublish_policy_file          = "custom_codepublish_file.json"
  environment_image_codebuild             = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codebuild              = "LINUX_CONTAINER"
  source_location_codebuild               = "https://github.com/pgetech/test_codepipeline_dotnet"
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
  environment_image_codetest              = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codetest               = "LINUX_CONTAINER"
  concurrent_build_limit_codetest         = 1
  compute_type_codetest                   = "BUILD_GENERAL1_SMALL"
  sg_name                                 = "sg_codebuild_dotnet_1121"
  sg_description                          = "security group for codebuild project dotnet"
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  sg_name_codebuild        = "sg_codebuild_codetest_project_dotnet_1121"
  sg_description_codebuild = "security group for codebuild - codetest project dotnet"
  cidr_egress_rules_codebuild = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  kms_name           = "codebuild_key_dotnet"
  kms_description    = "kms key for codebuild dotnet"
  sg_name_ec2        = "ec2-sg-1121"
  sg_description_ec2 = "Security group for example usage with Ec2 instance"
  cidr_ingress_rules_ec2 = [{
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 2049,
      to               = 2049,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.195.0/25"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules_ec2 = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  ec2_name                      = "ec2-deploy-dotnet-1121"
  ssm_parameter_golden_ami_name = "/ami/linux/golden"
  ec2_instance_type             = "t2.medium"
  ec2_az                        = "us-west-2c"
  root_block_device_volume_type = "gp3"
  root_block_device_throughput  = 200
  root_block_device_volume_size = 50
  codedeploy_role_service       = ["codedeploy.amazonaws.com"]
  codedeploy_app_name           = "codepipeline-dotnet-stco"
  deployment_tag_key            = "Name"
  deployment_type               = "IN_PLACE"
  deployment_option             = "WITHOUT_TRAFFIC_CONTROL"
}
