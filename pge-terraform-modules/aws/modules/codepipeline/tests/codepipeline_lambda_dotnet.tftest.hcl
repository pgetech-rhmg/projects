run "codepipeline_lambda_dotnet" {
  command = apply

  module {
    source = "./examples/codepipeline_lambda_dotnet"
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
  codepipeline_name            = "lambda-dotnet-ccoe-sample-aicg"
  repo_name                    = "test_codepipeline_dotnet"
  branch                       = "main"
  github_repo_url              = "https://github.com/pgetech/test_codepipeline_dotnet.git"
  github_org                   = "pgetech"
  project_root_directory       = "quickstart-dotnetcore-cicd"
  exclude_files                = "templates/*** docs/*** scripts/*** LICENSE.txt"
  dotnet_project_metadata_file = "appsettings.json"
  dotnet_runtime               = "6.0"
  unit_test_commands           = "dotnet test -c release --logger trx --results-directory ./testresults"
  bucket_name                  = "codepipeline-bucket-lambda-dotnet-aicg"
  artifact_bucket_owner_access = "FULL"
  artifact_path                = "codepipeline-new/"
  project_key                  = "lambda_dotnet_test_ccoe"
  project_name                 = "lambda_dotnet_test_ccoe"
  lambda_function_name         = "lambda-dotnet-api-test-aicg"
  lambda_alias_name            = "live" // Alias is mandatory to work with Lambda codepipeline 
  description                  = "testing aws lambda"
  dotnet_lambda_runtime        = "dotnet6"
  handler                      = "DASH.MessageProcessor.Lambda::DASH.MessageProcessor.Lambda.Function::FunctionHandler"
  lambda_timeout               = 120
  lambda_memory_size           = 512
  lambda_iam_name              = "codepipeline_lambda_dotnet_policy"
  lambda_iam_aws_service       = ["lambda.amazonaws.com"]
  lambda_iam_policy_arns       = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"]
  lambda_sg_name               = "codepipeline_lambda_dotnet_sg"
  lambda_sg_description        = "Security group for example usage with codepipeline lambda"
  lambda_cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  lambda_cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  ssm_parameter_vpc_id                    = "/vpc/id"
  ssm_parameter_subnet_id1                = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2                = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3                = "/vpc/2/privatesubnet3/id"
  ssm_parameter_artifactory_host          = "/jfrog/host"
  ssm_parameter_artifactory_repo_name     = "/jfrog/nuget/artifactory"
  ssm_parameter_sonar_host                = "/sonarqube/host"
  secretsmanager_artifactory_token        = "jfrog_credentials:jfrog_token"
  secretsmanager_artifactory_user         = "jfrog_credentials:jfrog_user"
  secretsmanager_sonar_token              = "sonarqube_credentials:sonar_token"
  secretsmanager_github_token_secret_name = "github_token_m7k3:pat"
  codebuild_role_service                  = ["codebuild.amazonaws.com"]
  codetest_role_name                      = "codetest_dotnet_iam_policy"
  codepipeline_role_service               = ["codepipeline.amazonaws.com"]
  environment_image_codebuild             = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  environment_type_codebuild              = "LINUX_CONTAINER"
  source_location_codebuild               = "https://github.com/pgetech/test_codepipeline_dotnet" // A redundant value for codepipeline; only required for standalobe codebuild project
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
  sg_name                                 = "sg_codebuild_lambda_dotnet"
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
  sg_name_codebuild        = "sg_codebuild_codetest_project"
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
}
