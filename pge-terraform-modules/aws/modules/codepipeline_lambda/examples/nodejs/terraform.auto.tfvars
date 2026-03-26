account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID              = "1001"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          # Order must be between 7 and 9 digits

optional_tags = {
  Name     = "test"
  pge_team = "ccoe-tf-developers"
}


lambda_function_name = "lambda-node-authorizer-aicg7"
lambda_alias_name    = "live"

codepipeline_name = "codepipeline-nodejs"
github_org        = "pgetech"
repo_name         = "terraform-cicd-pipeline-ref"
branch            = "main"


bucket_name                  = "codepipeline-lambda-node-aicg7"
artifact_bucket_owner_access = "FULL"
artifact_path                = "codepipeline-new/"

ssm_parameter_vpc_id                = "/vpc/id"
ssm_parameter_subnet_id1            = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2            = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3            = "/vpc/2/privatesubnet3/id"
ssm_parameter_artifactory_host      = "/jfrog/host"
ssm_parameter_artifactory_repo_name = "/jfrog/artifactory/ccoe_npm_repo" #ccoe-cicd-npm-virtual
ssm_parameter_sonar_host            = "/sonarqube/host"
secretsmanager_artifactory_token    = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user     = "jfrog_credentials:jfrog_user"
secretsmanager_sonar_token          = "sonarqube_credentials:sonar_token"

secretsmanager_github_token_secret_name = "github_token_r5vd:pat"


# For testing this example, we need to create a Github token
# and pass the value of token through ssm parameter store.
# provide the name of that parameter in the variable "token"
# warning appears in the console during "terraform apply" is due to using GitHub Version 1 since codesta ARN provided has some functional issues GitHub Version 1 is used.

project_key               = "lambda-nodejs-ccoe-test"
project_name              = "lambda-nodejs-ccoe-test"
project_root_directory    = "reference-pipelines/nodejs/lambda/azure-ad-authorizer"
dependency_files_location = ""
# unit_test_commands        = "npm test"
unit_test_commands        = ""
node_runtime              = "20"
sonar_scanner_cli_version = "5.0.1.3006" // The module has a default value of 5.0.1.3006. Users can override this value if needed.
#Iam_role
codebuild_role_service    = ["codebuild.amazonaws.com"]
codepipeline_role_service = ["codepipeline.amazonaws.com"]

#codebuild stage
environment_image_codebuild      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codebuild       = "LINUX_CONTAINER"
source_location_codebuild        = "https://github.com/pgetech/terraform-cicd-pipeline-ref.git" #"https://github.com/pgetech/nodejs-lambda-sample" 
concurrent_build_limit_codebuild = 1
compute_type_codebuild           = "BUILD_GENERAL1_SMALL"
#codescan stage
environment_image_codescan      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codescan       = "LINUX_CONTAINER"
concurrent_build_limit_codescan = 1
compute_type_codescan           = "BUILD_GENERAL1_SMALL"
#codepublish stage
environment_image_codepublish      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codepublish       = "LINUX_CONTAINER"
concurrent_build_limit_codepublish = 1
compute_type_codepublish           = "BUILD_GENERAL1_SMALL"

#optional env variables for codescan stage, remove this if not needed. mandatory attributes get's added in the buildspec. 
environment_variables_codescan_stage = [
  {
    name  = "OPTIONAL_ATTRIBUTES" #passing below additional attributes for sonar scan with tests and coverage report info
    value = "-Dsonar.coverage.exclusions=src/__test__/** -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info"
    type  = "PLAINTEXT"
  }
]
#security_group
sg_name        = "sg_codebuild"
sg_description = "security group for codebuild project node"
cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]

#Lambda
description = "testing aws lambda"
runtime     = "nodejs20.x"
handler     = "src/index.handler"

#security_group
lambda_sg_name        = "codepipeline_lambda_sg"
lambda_sg_description = "Security group for example usage with codepipeline lambda"

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

#Iam_role 
lambda_iam_name        = "codepipeline_lambda_node_policy_aicg7"
lambda_iam_aws_service = ["lambda.amazonaws.com"]
lambda_iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"]
