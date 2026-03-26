run "codepipeline_dockerimages" {
  command = apply

  module {
    source = "./examples/codepipeline_dockerimages"
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
    Name     = "codepipeline dockerimages"
    pge_team = "ccoe-tf-developers"
  }
  codepipeline_name                         = "dockerimages-pipeline-dev"
  repo_name                                 = "pge-java-spring-petclinic"
  github_org                                = "pgetech"
  branch                                    = "test"
  app_owners                                = "m7k3_ab1c"
  artifact_bucket_owner_access              = "FULL"
  artifact_path                             = "codepipeline-docker/"
  secretsmanager_github_token_secret_name   = "github_token_m7k3:pat"
  ssm_parameter_vpc_id                      = "/vpc/id"
  ssm_parameter_subnet_id1                  = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                  = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3                  = "/vpc/2/privatesubnet3/id"
  ssm_parameter_artifactory_host            = "/jfrog/url"
  ssm_parameter_twistlock_console           = "/twistlock/console_url"
  ssm_parameter_artifactory_docker_registry = "/jfrog/ccoe-cicd/docker-registry"
  secretsmanager_artifactory_token          = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user           = "jfrog_credentials:jfrog_user"
  secretsmanager_twistlock_user_id          = "shared-twistlock-access:PRISMA_KEY"
  secretsmanager_twistlock_token            = "shared-twistlock-access:PRISMA_SECRET"
  codebuild_role_service                    = ["codebuild.amazonaws.com"]
  codepipeline_role_service                 = ["codepipeline.amazonaws.com"]
  environment_image_codebuild               = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codebuild                = "LINUX_CONTAINER"
  source_location_codebuild                 = "https://github.com/pgetech/pge-java-spring-petclinic"
  concurrent_build_limit_codebuild          = 2
  compute_type_codebuild                    = "BUILD_GENERAL1_LARGE"
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
  DockerImage_name = "alpine-test-pipeline"
  endpoint_email   = ["m7k3@pge.com"]
}
