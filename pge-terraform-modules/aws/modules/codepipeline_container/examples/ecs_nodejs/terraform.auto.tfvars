account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"


AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Applicable envs - Dev, Test, QA, Prod
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205 #Order tag is required and must be a number between 7 and 9 digits
optional_tags = {
  Name     = "Container pipeline"
  pge_team = "ccoe-tf-developers"
}


codepipeline_name = "ecs-nodejs-rr5vd"
github_org        = "pgetech"
repo_name         = "terraform-cicd-pipeline-ref"
branch            = "main"
project_key       = "pge-container-nodeecs-test"
project_name      = "pge-container-nodeecs-test"


artifact_bucket_owner_access = "FULL"
artifact_path                = "codepipeline-new/"
s3_force_destroy             = true
s3_block_public_policy       = true

secretsmanager_github_token_secret_name = "github_token_r5vd:pat"

ssm_parameter_vpc_id                      = "/vpc/id"
ssm_parameter_subnet_id1                  = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2                  = "/vpc/2/privatesubnet2/id"
ssm_parameter_artifactory_host            = "/jfrog/url"
ssm_parameter_artifactory_repo_name       = "/jfrog/artifactory/ccoe_nodejs_repo"
ssm_parameter_sonar_host                  = "/sonar/host"
ssm_parameter_artifactory_docker_registry = "/jfrog/ccoe-cicd/docker-registry"



secretsmanager_artifactory_token = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user  = "jfrog_credentials:jfrog_user"
secretsmanager_sonar_token       = "sonarqube_credentials:sonar_token"

secretsmanager_wiz_client_secret = "shared-wiz-access:WIZ_CLIENT_SECRET"
secretsmanager_wiz_client_id     = "shared-wiz-access:WIZ_CLIENT_ID"

project_root_directory    = "reference-pipelines/nodejs/ecs-eks/nodejs-webapp" #leave it empty if your source code is on root directory
node_runtime              = "20"
sonar_scanner_cli_version = "5.0.1.3006" // The module has a default value of 5.0.1.3006. Users can override this value if needed.
unit_test_commands        = "npm start & npm test"
node_build                = "npm cache clean --force & rm -rf node_modules & npm install"
image_type                = "pge-app"
app_owners                = "su1y_a8dv_sycz"


#Iam_role
codebuild_role_service    = ["codebuild.amazonaws.com"]
codepipeline_role_service = ["codepipeline.amazonaws.com"]
#codebuild stage
environment_image_codebuild      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codebuild       = "LINUX_CONTAINER"
source_location_codebuild        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codebuild = 2
compute_type_codebuild           = "BUILD_GENERAL1_LARGE"
#codescan stage
environment_image_codescan      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codescan       = "LINUX_CONTAINER"
source_location_codescan        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codescan = 2
compute_type_codescan           = "BUILD_GENERAL1_LARGE"
#codepublish stage
environment_image_codepublish      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codepublish       = "LINUX_CONTAINER"
source_location_codepublish        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codepublish = 2
compute_type_codepublish           = "BUILD_GENERAL1_LARGE"

#codetest
environment_image_codetest      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codetest       = "LINUX_CONTAINER"
source_location_codetest        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codetest = 2
compute_type_codetest           = "BUILD_GENERAL1_LARGE"

#secretsscan stage
environment_image_codesecret = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codesecret  = "LINUX_CONTAINER"
#source_location_codesecret        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
source_location_codesecret        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codesecret = 2
compute_type_codesecret           = "BUILD_GENERAL1_LARGE"

#security_group
sg_description = "security group for codebuild project nodejs-example"
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
#codebuild - codetest security group
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

#kms_key
kms_name        = "codebuild_key_nodejs-test"
kms_description = "kms key for codebuild java"

#codeDeploy for Rolling Update
codedeploy_role_service       = ["codedeploy.amazonaws.com"]
deployment_stage_name         = "nodejs-example-deploy"
codedeploy_provider           = "ECS"
container_name                = "node-web-app"
version_file                  = "package.json"
task_definition_template_path = "taskdef.json"
appspec_template_path         = "appspec.yaml"
image1_container_name         = "IMAGE1_NAME"

#ECS task definition

ecs_cluster_name = "s7aw-cluster"
ecs_service_name = "node-web-app"

deployment_timeout = 30 # CodeDeploy will time out if deployment is not compelted in 30mins

# Container build environment
privileged_mode         = true
publish_docker_registry = "ECR" # Possible values are ECR or JFROG or BOTH

######################### SNS ###############################
endpoint_email = [] # Endpoint to send data to. The contents vary with the protocol.
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
