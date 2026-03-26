run "ecs_java" {
  command = apply

  module {
    source = "./examples/ecs_java"
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
  Order              = 8115205
  optional_tags = {
    Name     = "Container pipeline"
    pge_team = "ccoe-tf-developers"
  }
  codepipeline_name                         = "ecs-java-r5vd"
  github_org                                = "pgetech"
  repo_name                                 = "terraform-cicd-pipeline-ref"
  branch                                    = "main"
  project_name                              = "spring-petclinic-bluegreen-r5vd"
  project_key                               = "spring-petclinic-bluegreen-r5vd"
  artifact_bucket_owner_access              = "FULL"
  artifact_path                             = "codepipeline-new/"
  secretsmanager_github_token_secret_name   = "github_token_r5vd:pat"
  ssm_parameter_vpc_id                      = "/vpc/id"
  ssm_parameter_subnet_id1                  = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                  = "/vpc/2/privatesubnet2/id"
  ssm_parameter_artifactory_host            = "/jfrog/host"
  ssm_parameter_artifactory_repo_name       = "/jfrog/artifactory/ccoe_maven_repo"
  ssm_parameter_sonar_host                  = "/sonarqube/host"
  ssm_parameter_artifactory_docker_registry = "/jfrog/ccoe-cicd/docker-registry"
  secretsmanager_artifactory_token          = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user           = "jfrog_credentials:jfrog_user"
  secretsmanager_sonar_token                = "sonarqube_credentials:sonar_token"
  secretsmanager_wiz_client_secret          = "shared-wiz-access:WIZ_CLIENT_SECRET"
  secretsmanager_wiz_client_id              = "shared-wiz-access:WIZ_CLIENT_ID"
  project_root_directory                    = "reference-pipelines/java/ecs-eks/pge-java-spring-petclinic"
  java_runtime                              = "corretto17"
  codebuild_role_service                    = ["codebuild.amazonaws.com"]
  codepipeline_role_service                 = ["codepipeline.amazonaws.com"]
  environment_image_codebuild               = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codebuild                = "LINUX_CONTAINER"
  source_location_codebuild                 = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codebuild          = 2
  compute_type_codebuild                    = "BUILD_GENERAL1_LARGE"
  environment_image_codescan                = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codescan                 = "LINUX_CONTAINER"
  source_location_codescan                  = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codescan           = 2
  compute_type_codescan                     = "BUILD_GENERAL1_LARGE"
  environment_image_codepublish             = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codepublish              = "LINUX_CONTAINER"
  source_location_codepublish               = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codepublish        = 2
  compute_type_codepublish                  = "BUILD_GENERAL1_LARGE"
  environment_image_codetest                = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codetest                 = "LINUX_CONTAINER"
  source_location_codetest                  = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codetest           = 2
  compute_type_codetest                     = "BUILD_GENERAL1_LARGE"
  environment_image_codesecret              = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codesecret               = "LINUX_CONTAINER"
  source_location_codesecret                = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codesecret         = 2
  compute_type_codesecret                   = "BUILD_GENERAL1_LARGE"
  sg_description                            = "security group for codebuild project java"
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    }
    ,
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.91.129.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
    }
  ]
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
  kms_name                      = "codebuild_kms_key_r5vd"
  kms_description               = "kms key for codebuild java"
  ecs_service_name              = "springapp-oxdi-test-new"
  codedeploy_role_service       = ["codedeploy.amazonaws.com"]
  codedeploy_provider           = "CodeDeployToECS"
  task_definition_template_path = "taskdef.json"
  appspec_template_path         = "appspec.yaml"
  image1_container_name         = "IMAGE1_NAME"
  container_name                = "springapp-container"
  ecs_cluster_name              = "ecs-ec2-bg-java-cluster-oxdi"
  deployment_timeout            = 30
  privileged_mode               = true
  publish_docker_registry       = "JFROG"
  endpoint_email                = []
  cidr_egress_rules_SNS_codestar = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
}
