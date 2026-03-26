run "codepipeline_terraform" {
  command = apply

  module {
    source = "./examples/codepipeline_terraform"
  }
}

variables {
  account_num        = "241689241215"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  aws_org_id         = "ou-nfqe-uk6yg06j"
  AppID              = "2781"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["tahv@pge.com", "j2tw@pge.com"]
  Owner              = ["tahv", "j2tw", "b1v6"]
  Compliance         = ["None"]
  optional_tags = {
    Name     = "ccoe-ssm-autopatch-pipeline"
    pge_team = "cceo-devops"
  }
  codepipeline_name                       = "ccoe-ssm-autopatch-pipeline"
  github_org                              = "pgetech"
  repo_name                               = "ccoe-ssm-autopatch-mgt"
  branch                                  = "main"
  pollchanges                             = false
  project_key                             = "ccoe-ssm-autopatch-pipeline"
  project_name                            = "ccoe-ssm-autopatch-pipeline"
  bucket_name                             = "ccoe-ssm-autopatch-bucket"
  artifact_bucket_owner_access            = "FULL"
  artifact_path                           = "codepipeline-data/"
  ssm_parameter_vpc_id                    = "/vpc/id"
  ssm_parameter_subnet_id1                = "/vpc/privatesubnet1/id"
  ssm_parameter_subnet_id2                = "/vpc/privatesubnet2/id"
  ssm_parameter_subnet_id3                = "/vpc/privatesubnet3/id"
  ssm_parameter_artifactory_host          = "/jfrog/cscoe-host"
  ssm_parameter_artifactory_repo_name     = "/jfrog/cscoe-pypi"
  ssm_parameter_sonar_host                = "/sonarqube/host"
  secretsmanager_artifactory_token        = "/jfrog/cscoe-token"
  secretsmanager_artifactory_user         = "/jfrog/cscoe-username"
  secretsmanager_sonar_token              = "/sonarqube/token"
  secretsmanager_terraform_token          = "terraform_token_sycz"
  secretsmanager_github_token_secret_name = "/github/ccoe-iam-pipeline-pat"
  secretsmanager_ccoe_ssm_patch_pat       = "/github/ccoe-ssm-patch-pat"
  project_root_directory                  = "gen-tfc"
  github_repo_url                         = "https://github.com/pgetech/ccoe-ssm-autopatch-pipeline.git"
  dependency_files_location               = "./requirements.txt"
  unit_test_commands                      = "provide-unit-test-commands-here"
  python_runtime                          = "3.8"
  codebuild_role_service                  = ["codebuild.amazonaws.com"]
  codebuild_additional_policy             = "codebuild_additional_policy.json"
  codetest_role_name                      = "codetest_python_iam_policy"
  codepipeline_role_service               = ["codepipeline.amazonaws.com"]
  environment_image_codebuild             = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codebuild              = "LINUX_CONTAINER"
  source_location_codebuild               = "https://github.com/pgetech/test_codepipeline_python"
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
  sg_name                                 = "sg_codebuild_project"
  sg_description                          = "security group for codebuild project python"
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  sg_name_codebuild        = "sg_codebuild_codetest_project"
  sg_description_codebuild = "security group for codebuild - codetest project python"
  cidr_egress_rules_codebuild = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  s3_kms_key_arn     = "arn:aws:kms:us-west-2:241689241215:key/37752006-4a9a-4c77-880f-da27286bda52"
  sg_name_ec2        = "ec2-sg"
  sg_description_ec2 = "Security group for example usage with Ec2 instance"
  cidr_ingress_rules_ec2 = [{
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.0.0.0/8"]
    ipv6_cidr_blocks = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 2049,
      to               = 2049,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.195.0/25"]
      ipv6_cidr_blocks = []
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
  ec2_name                      = "ec2-python-deploy"
  ssm_parameter_golden_ami_name = "/ami/linux/golden"
  ec2_instance_type             = "t2.micro"
  ec2_az                        = "us-west-2c"
  root_block_device_volume_type = "gp3"
  root_block_device_throughput  = 200
  root_block_device_volume_size = 50
  codedeploy_app_name           = "codepipeline-autopatch-python"
  deployment_tag_key            = "Name"
  deployment_tag_value          = "ec2-python-deploy"
  deployment_type               = "IN_PLACE"
}
