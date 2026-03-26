run "codepipeline_artifact_download_java" {
  command = apply

  module {
    source = "./examples/codepipeline_artifact_download_java"
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
  optional_tags = {
    Name     = "test"
    pge_team = "ccoe-tf-developers"
  }
  codepipeline_name                       = "codepipeline-java-artifact-download"
  github_org                              = "pgetech"
  repo_name                               = "terraform-cicd-pipeline-ref"
  branch                                  = "main"
  project_key                             = "codepipeline-java-ccoe-test"
  project_name                            = "codepipeline-java-ccoe-test"
  artifact_bucket_owner_access            = "FULL"
  artifact_path                           = "codepipeline-new/"
  bucket_name                             = "codepipeline-java-artifact-download"
  secretsmanager_github_token_secret_name = "github_token_m7k3:pat"
  ssm_parameter_vpc_id                    = "/vpc/id"
  ssm_parameter_subnet_id1                = "/vpc/privatesubnet1/id"
  ssm_parameter_subnet_id2                = "/vpc/privatesubnet2/id"
  ssm_parameter_subnet_id3                = "/vpc/privatesubnet3/id"
  ssm_parameter_artifactory_host          = "/jfrog/host"
  ssm_parameter_artifactory_repo_name     = "/jfrog/artifactory/ccoe_maven_repo"
  ssm_parameter_sonar_host                = "/sonarqube/host"
  secretsmanager_artifactory_token        = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user         = "jfrog_credentials:jfrog_user"
  secretsmanager_sonar_token              = "sonarqube_credentials:sonar_token"
  github_repo_url                         = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  dependency_file_location                = ""
  project_root_directory                  = "reference-pipelines/java/ec2/springboot-war-example"
  java_runtime                            = "corretto17"
  codebuild_role_service                  = ["codebuild.amazonaws.com"]
  codetest_role_name                      = "codetest_java_iam_policy"
  codepipeline_role_service               = ["codepipeline.amazonaws.com"]
  environment_image_codescan              = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codescan               = "LINUX_CONTAINER"
  source_location_codescan                = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codescan         = 1
  compute_type_codescan                   = "BUILD_GENERAL1_SMALL"
  environment_image_codetest              = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codetest               = "LINUX_CONTAINER"
  source_location_codetest                = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codetest         = 1
  compute_type_codetest                   = "BUILD_GENERAL1_SMALL"
  environment_image_codedownload          = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codedownload           = "LINUX_CONTAINER"
  source_location_codedownload            = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codedownload     = 1
  compute_type_codedownload               = "BUILD_GENERAL1_SMALL"
  sg_name                                 = "sg_codebuild_project_download_java"
  sg_description                          = "security group for codebuild project java"
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  sg_name_codebuild        = "sg_codebuild_codetest_download_java"
  sg_description_codebuild = "security group for codebuild - codetest project java"
  cidr_egress_rules_codebuild = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  kms_name           = "codebuild_key_java-artifact-download"
  kms_description    = "kms key for codebuild java"
  sg_name_ec2        = "ec2-sg-java-artifact-download"
  sg_description_ec2 = "Security group for example usage with Ec2 instance"
  cidr_ingress_rules_ec2 = [{
    from             = 8443,
    to               = 8443,
    protocol         = "tcp",
    cidr_blocks      = ["10.0.0.0/8"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules - 1"
    },
    {
      from             = 8443,
      to               = 8443,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.0.0/21"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules - 2"
    },
    {
      from             = 8443,
      to               = 8443,
      protocol         = "tcp",
      cidr_blocks      = ["172.30.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "sample ec2 ingress rules - 1"
    },
    {
      from             = 8443,
      to               = 8443,
      protocol         = "tcp",
      cidr_blocks      = ["192.168.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "sample ec2 ingress rules - 2"
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
  ec2_name                      = "java-ec2"
  ssm_parameter_golden_ami_name = "/ami/linux/golden"
  ec2_instance_type             = "t2.micro"
  ec2_az                        = "us-west-2c"
  root_block_device_volume_type = "gp3"
  root_block_device_throughput  = 200
  root_block_device_volume_size = 50
  metadata_http_endpoint        = "enabled"
  codedeploy_role_service       = ["codedeploy.amazonaws.com"]
  codedeploy_app_name           = "codepipeline-java-download"
  deployment_tag_key            = "Name"
  deployment_tag_value          = "java-ec2"
  deployment_type               = "IN_PLACE"
  download_artifact             = true
  sonar_branch_scanned          = "main"
}
