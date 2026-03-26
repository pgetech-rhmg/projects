account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          # Order must be between 7 and 9 digits 

optional_tags = {
  Name     = "test"
  pge_team = "ccoe-tf-developers"
}

codepipeline_name = "nodejs-r5vd"
github_org        = "pgetech"
repo_name         = "terraform-cicd-pipeline-ref"
branch            = "main"

artifact_bucket_owner_access = "FULL"
artifact_path                = "codepipeline-new/"
bucket_name                  = "codepipeline-bucket-nodejs-1121"
metadata_http_endpoint       = "enabled"

unit_test_commands = "npm run test"

# For testing this example, we need to create a Github token
# and pass the value of token through ssm parameter store.
# provide the name of that parameter in the variable "ssm_parameter_github_oauth_token"
# warning appears in the console during "terraform apply" is due to using GitHub Version 1 since codesta ARN provided has some functional issues GitHub Version 1 is used.
# Provide the suitable github oauth token in the variable 'ssm_parameter_github_oauth_token' for testing.

secretsmanager_github_token_secret_name = "github_token_stco:pat"

ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
#Buildspec_spec environment values
ssm_parameter_artifactory_host      = "/jfrog/host"
ssm_parameter_artifactory_repo_name = "/jfrog/npm/artifactory"
ssm_parameter_sonar_host            = "/sonarqube/host"
secretsmanager_artifactory_token    = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user     = "jfrog_credentials:jfrog_user"
secretsmanager_sonar_token          = "sonarqube_credentials:sonar_token"
project_name                        = "codepipeline_nodejs_m7k3"
project_root_directory              = "reference-pipelines/nodejs/ec2/sample-nodejs" #leave it empty if it's on root
artifact_name_nodejs                = "codepipeline_nodejs_m7k3"                     ## unused variable in the module, it will be removed in the next version.
nodejs_version                      = "18"
project_key                         = "codepipeline_nodejs_m7k3"
github_branch                       = "main"


#Iam_role
codebuild_role_service    = ["codebuild.amazonaws.com"]
codetest_role_name        = "codetest_nodejs_iam_policy_dl"
codepipeline_role_service = ["codepipeline.amazonaws.com"]
#codebuild stage
environment_image_codebuild      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codebuild       = "LINUX_CONTAINER"
source_location_codebuild        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codebuild = 1
compute_type_codebuild           = "BUILD_GENERAL1_SMALL"
#codescan stage
environment_image_codescan = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codescan  = "LINUX_CONTAINER"
# source_location_codescan        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codescan = 1
compute_type_codescan           = "BUILD_GENERAL1_SMALL"
#codepublish stage
environment_image_codepublish = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codepublish  = "LINUX_CONTAINER"
# source_location_codepublish        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codepublish = 1
compute_type_codepublish           = "BUILD_GENERAL1_SMALL"
#codetest
environment_image_codetest      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codetest       = "LINUX_CONTAINER"
concurrent_build_limit_codetest = 1
compute_type_codetest           = "BUILD_GENERAL1_SMALL"
#security_group
sg_name        = "codebuild_project_nodejs_dl"
sg_description = "security group for codebuild project nodejs"
cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]
#codebuild - codetest security group
sg_name_codebuild        = "sg_codebuild_codetest_project_nodejs_1121"
sg_description_codebuild = "security group for codebuild - codetest project nodejs"
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
kms_name        = "codebuild_key_nodejs_1121"
kms_description = "kms key for codebuild nodejs"

#EC2
sg_name_ec2        = "ec2-sg-nodejs-dl"
sg_description_ec2 = "Security group for example usage with Ec2 instance"

cidr_ingress_rules_ec2 = [{
  from             = 443,
  to               = 443,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.195.0/25"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
  },
  {
    from             = 8080,
    to               = 8080,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
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

ec2_name                      = "ec2-deploy-node-dl"
ssm_parameter_golden_ami_name = "/ami/linux/golden"
ec2_instance_type             = "t2.micro"
ec2_az                        = "us-west-2c"
root_block_device_volume_type = "gp3"
root_block_device_throughput  = 200
root_block_device_volume_size = 50

#codeDeploy
codedeploy_role_service = ["codedeploy.amazonaws.com"]
codedeploy_app_name     = "codepipeline-nodejs-dl"
deployment_tag_key      = "Name"
# deployment_tag_value    = "ec2-deploy-node"
deployment_type = "IN_PLACE"
