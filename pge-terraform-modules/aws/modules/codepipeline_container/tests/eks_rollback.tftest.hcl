run "eks_rollback" {
  command = apply

  module {
    source = "./examples/eks_rollback"
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
  codepipeline_name                       = "springpetclinic-aicg-eks"
  repo_name                               = "pge-java-spring-petclinic"
  branch                                  = "e6bo-patch-1"
  pollchanges                             = false
  artifact_path                           = "codepipeline-new/"
  secretsmanager_github_token_secret_name = "github_token_r5vd:pat"
  github_org                              = "pgetech"
  ssm_parameter_vpc_id                    = "/vpc/id"
  ssm_parameter_subnet_id1                = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                = "/vpc/2/privatesubnet3/id"
  ssm_parameter_artifactory_host          = "/jfrog/url"
  secretsmanager_artifactory_token        = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user         = "jfrog_credentials:jfrog_user"
  project_root_directory                  = ""
  java_runtime                            = "corretto17"
  environment_image_helmchart             = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  environment_type_helmchart              = "LINUX_CONTAINER"
  source_location_helmchart               = "https://github.com/pgetech/pge-java-spring-petclinic"
  concurrent_build_limit_helmchart        = 2
  compute_type_helmchart                  = "BUILD_GENERAL1_LARGE"
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
  notification_message = "Hi, Please approve rollback request for the Spring Petclinic Application"
  eks_cluster_name     = "node-12"
  chart_revision       = "3"
  namespace            = "petclinic-app"
  container_name       = "spring-petclinic"
  endpoint_email       = []
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
