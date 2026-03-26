run "eks_java" {
  command = apply

  module {
    source = "./examples/eks_java"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  aws_r53_role       = "CloudAdmin"
  custom_domain_name = "sukx1.eks-java-acmtfc.nonprod.pge.com"
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
  codepipeline_name                           = "petclinic-eks-r5vd"
  github_org                                  = "pgetech"
  repo_name                                   = "pge-java-spring-petclinic"
  branch                                      = "e6bo-patch-1"
  project_key                                 = "petclinic-eks-ru"
  project_name                                = "petclinic-eks-ru"
  secretsmanager_github_token_secret_name     = "github_token_r5vd:pat"
  ssm_parameter_vpc_id                        = "/vpc/id"
  ssm_parameter_subnet_id1                    = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                    = "/vpc/2/privatesubnet2/id"
  ssm_parameter_artifactory_host              = "/jfrog/url"
  ssm_parameter_sonar_host                    = "/sonar/host"
  ssm_parameter_artifactory_docker_registry   = "/jfrog/ccoe-cicd/docker-registry"
  ssm_parameter_artifactory_helm_virtual_repo = "/jfrog/ccoe-cicd-helm-virtual/repo"
  ssm_parameter_artifactory_helm_local_repo   = "/jfrog/ccoe-cicd-helm-local/repo"
  secretsmanager_artifactory_token            = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user             = "jfrog_credentials:jfrog_user"
  secretsmanager_sonar_token                  = "sonarqube_credentials:sonar_token"
  secretsmanager_wiz_client_secret            = "shared-wiz-access:WIZ_CLIENT_SECRET"
  secretsmanager_wiz_client_id                = "shared-wiz-access:WIZ_CLIENT_ID"
  project_root_directory                      = ""
  java_runtime                                = "corretto17"
  environment_image_codebuild                 = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codebuild                  = "LINUX_CONTAINER"
  source_location_codebuild                   = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codebuild            = 2
  compute_type_codebuild                      = "BUILD_GENERAL1_LARGE"
  environment_image_codescan                  = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codescan                   = "LINUX_CONTAINER"
  source_location_codescan                    = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codescan             = 2
  compute_type_codescan                       = "BUILD_GENERAL1_LARGE"
  environment_image_codepublish               = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codepublish                = "LINUX_CONTAINER"
  source_location_codepublish                 = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codepublish          = 2
  compute_type_codepublish                    = "BUILD_GENERAL1_LARGE"
  environment_image_helmchart                 = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_helmchart                  = "LINUX_CONTAINER"
  source_location_helmchart                   = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_helmchart            = 2
  compute_type_helmchart                      = "BUILD_GENERAL1_LARGE"
  environment_image_codesecret                = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codesecret                 = "LINUX_CONTAINER"
  source_location_codesecret                  = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
  concurrent_build_limit_codesecret           = 2
  compute_type_codesecret                     = "BUILD_GENERAL1_LARGE"
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
  cidr_egress_rules_codebuild = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  privileged_mode         = true
  publish_docker_registry = "BOTH"
  eks_cluster_name        = "newtest"
  container_name          = "sample-petclinic" // It should match the name in Chart.yaml; the repository image in values.yaml
  namespace               = "app-r5vd"
  cidr_egress_rules_SNS_codestar = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  endpoint_email = []
}
