run "codepipeline_eks_nodejs" {
  command = apply

  module {
    source = "./examples/codepipeline_eks_nodejs"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  aws_r53_role       = "TFCBR53Role"
  custom_domain_name = "eks-nodes-m7k3.nonprod.pge.com"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  optional_tags = {
    Name     = "Container pipeline"
    pge_team = "ccoe-tf-developers"
  }
  codepipeline_name                           = "node-web-app-eks-m7k3"
  github_org                                  = "pgetech"
  repo_name                                   = "nodejs-webapp"
  branch                                      = "main"
  project_key                                 = "node-web-app-eks-m7k3"
  project_name                                = "node-web-app-eks-m7k3"
  artifact_bucket_owner_access                = "FULL"
  artifact_path                               = "codepipeline-new/"
  s3_force_destroy                            = true
  s3_block_public_policy                      = true
  ssm_parameter_vpc_id                        = "/vpc/id"
  ssm_parameter_subnet_id1                    = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                    = "/vpc/2/privatesubnet2/id"
  ssm_parameter_artifactory_host              = "/jfrog/url"
  ssm_parameter_artifactory_nodejs_repo       = "/jfrog/artifactory/ccoe_nodejs_repo"
  ssm_parameter_sonar_host                    = "/sonar/host"
  ssm_parameter_twistlock_console             = "/twistlock/console_url"
  ssm_parameter_artifactory_docker_registry   = "/jfrog/ccoe-cicd/docker-registry"
  ssm_parameter_artifactory_helm_virtual_repo = "/jfrog/ccoe-cicd-helm-virtual/repo"
  ssm_parameter_artifactory_helm_local_repo   = "/jfrog/ccoe-cicd-helm-local/repo"
  secretsmanager_github_token_secret_name     = "github_token_m7k3:pat"
  secretsmanager_artifactory_token            = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user             = "jfrog_credentials:jfrog_user"
  secretsmanager_sonar_token                  = "sonarqube_credentials:sonar_token"
  secretsmanager_twistlock_user_id            = "shared-twistlock-access:PRISMA_KEY"
  secretsmanager_twistlock_token              = "shared-twistlock-access:PRISMA_SECRET"
  project_root_directory                      = ""
  nodejs_runtime                              = "20"
  unit_test_commands                          = "npm start & npm test"
  build_command                               = "npm cache clean --force & rm -rf node_modules & npm install"
  image_type                                  = "pge-app"
  app_owners                                  = "su1y_a8dv_sycz"
  codebuild_role_service                      = ["codebuild.amazonaws.com"]
  codepipeline_role_service                   = ["codepipeline.amazonaws.com"]
  environment_image_codebuild                 = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codebuild                  = "LINUX_CONTAINER"
  source_location_codebuild                   = "https://github.com/pgetech/nodejs-webapp"
  concurrent_build_limit_codebuild            = 2
  compute_type_codebuild                      = "BUILD_GENERAL1_LARGE"
  environment_image_codescan                  = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codescan                   = "LINUX_CONTAINER"
  source_location_codescan                    = "https://github.com/pgetech/nodejs-webapp"
  concurrent_build_limit_codescan             = 2
  compute_type_codescan                       = "BUILD_GENERAL1_LARGE"
  environment_image_codepublish               = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codepublish                = "LINUX_CONTAINER"
  source_location_codepublish                 = "https://github.com/pgetech/nodejs-webapp"
  concurrent_build_limit_codepublish          = 2
  compute_type_codepublish                    = "BUILD_GENERAL1_LARGE"
  environment_image_helmchart                 = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_helmchart                  = "LINUX_CONTAINER"
  source_location_helmchart                   = "https://github.com/pgetech/nodejs-webapp"
  concurrent_build_limit_helmchart            = 2
  compute_type_helmchart                      = "BUILD_GENERAL1_LARGE"
  environment_image_codesecret                = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codesecret                 = "LINUX_CONTAINER"
  source_location_codesecret                  = "https://github.com/pgetech/nodejs-webapp"
  concurrent_build_limit_codesecret           = 2
  compute_type_codesecret                     = "BUILD_GENERAL1_LARGE"
  sg_description                              = "security group for codebuild project nodejs-example"
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
  sg_description_codebuild = "security group for codebuild - codetest project nodejs-example"
  cidr_egress_rules_codebuild = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  kms_name                = "codebuild_key_nodej-arb"
  kms_description         = "kms key for codebuild java"
  eks_cluster_name        = "newclusterdev"
  container_name          = "node-web-app"
  version_file            = "package.json"
  namespace               = "app-node-web"
  privileged_mode         = true
  publish_docker_registry = "BOTH"
  endpoint_email          = []
  cidr_egress_rules_SNS_codestar = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  codestar_environment = "dev"
}
