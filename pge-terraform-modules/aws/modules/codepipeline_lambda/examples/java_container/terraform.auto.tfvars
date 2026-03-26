account_num        = "750713712981"
aws_account_number = "750713712981"
aws_region         = "us-west-2"
aws_role           = "CloudAdmin"

AppID              = 1001                                             # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
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

codepipeline_name = "java-docker-cp"
github_org        = "pgetech"
repo_name         = "terraform-cicd-pipeline-ref"
branch            = "main"
container_name    = "test"


bucket_name = "lambda-java-docker-cp"

ssm_parameter_vpc_id                      = "/vpc/id"
ssm_parameter_subnet_id1                  = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2                  = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3                  = "/vpc/2/privatesubnet3/id"
ssm_parameter_artifactory_host            = "/jfrog/host"
ssm_parameter_artifactory_docker_registry = "/jfrog/ccoe-cicd/docker-registry"
ssm_parameter_sonar_host                  = "/sonarqube/host"
secretsmanager_artifactory_token          = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user           = "jfrog_credentials:jfrog_user"
secretsmanager_sonar_token                = "sonarqube_credentials:sonar_token"

secretsmanager_github_token_secret_name = "github_token_stco:pat"

project_key               = "lambda-java-docker-ccoe-test" #project key for sonarqube scan
project_name              = "lambda-java-docker-ccoe-test" #Make sure to project Name for sonarqube scan which will be used to create a project in sonarqube
dependency_files_location = "pom.xml"
java_runtime              = "corretto17"
unit_test_commands        = "mvn test"
sonar_scanner_cli_version = "5.0.1.3006" // The module has a default value of 5.0.1.3006. Users can override this value if needed.

# CodeBuild configuration
codebuild_role_service    = ["codebuild.amazonaws.com"]
codepipeline_role_service = ["codepipeline.amazonaws.com"]

#codebuild stage
environment_image_codebuild      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codebuild       = "LINUX_CONTAINER"
source_location_codebuild        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codebuild = 1
compute_type_codebuild           = "BUILD_GENERAL1_MEDIUM"

#codescan stage
environment_image_codescan      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codescan       = "LINUX_CONTAINER"
concurrent_build_limit_codescan = 1
compute_type_codescan           = "BUILD_GENERAL1_SMALL"
source_location_codescan        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"

#codepublish stage
environment_image_codepublish      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codepublish       = "LINUX_CONTAINER"
concurrent_build_limit_codepublish = 1
compute_type_codepublish           = "BUILD_GENERAL1_MEDIUM"
source_location_codepublish        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"

artifact_path                = ""
artifact_bucket_owner_access = "FULL"

# Docker specific variables
docker_image_name       = "test"
publish_docker_registry = "ECR" # or "JFROG" or "BOTH"
app_owners              = "PGE-DevOps"


# Lambda configuration
lambda_function_name   = "java-docker-lambda-function-stco"
lambda_alias_name      = "live"
lambda_update          = true
include_lib_files      = true
description            = "Java Lambda function using Docker containers"
project_root_directory = "reference-pipelines/java/ecs-eks/pge-java-spring-petclinic" #if source code is not in the root directory

source_location_wizscan = "https://github.com/pgetech/terraform-cicd-pipeline-ref"

allow_outofband_update = true

# Placeholder for Lambda image URI used by the Terraform `lambda_image` module.
# Leave empty to skip creating an image-based Lambda until a real image exists.
image_uri = "750713712981.dkr.ecr.us-west-2.amazonaws.com/test:pge-2.7.2"

# ARN of the IAM role that Lambda should assume when created by the publish buildspec.
# If you want the publish stage to create the Lambda, set this to a valid execution role ARN.

runtime = "java17"
handler = "example.HandlerIntegerJava17"

#lambda security_group
lambda_sg_name        = "codepipeline_lambda_java_sg"
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

#lambda Iam_role 
lambda_iam_name        = "codepipeline_lambda_java_policy"
lambda_iam_aws_service = ["lambda.amazonaws.com"]
lambda_iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"]

secretsmanager_wiz_client_secret = "shared-wiz-access:WIZ_CLIENT_SECRET"
secretsmanager_wiz_client_id     = "shared-wiz-access:WIZ_CLIENT_ID"
image_tag                        = "pge-2.7.2"