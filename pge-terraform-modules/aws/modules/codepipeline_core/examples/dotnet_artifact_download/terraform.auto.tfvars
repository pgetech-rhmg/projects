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

codepipeline_name = "artifact-dotnet"
github_org        = "pgetech"
repo_name         = "terraform-cicd-pipeline-ref"
branch            = "main"
# build_args             = "dev"
metadata_http_endpoint = "enabled"

artifact_bucket_owner_access = "FULL"
artifact_path                = "codepipeline-new/"
bucket_name                  = "codepipeline-bucket-dotnet"

# For testing this example, we need to create a Github token
# and pass the value of token through ssm parameter store.
# provide the name of that parameter in the variable "secretsmanager_github_token_secret_name"
# warning appears in the console during "terraform apply" is due to using GitHub Version 1 since codesta ARN provided has some functional issues GitHub Version 1 is used.
# Provide the suitable github oauth token in the variable 'secretsmanager_github_token_secret_name' for testing.

secretsmanager_github_token_secret_name = "github_token_stco:pat"
secretsmanager_artifactory_token        = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user         = "jfrog_credentials:jfrog_user"
secretsmanager_sonar_token              = "sonarqube_credentials:sonar_token"

ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"

#Buildspec_spec environment values
ssm_parameter_artifactory_host     = "/jfrog/host"
ssm_parameter_artifactory_repo_key = "/jfrog/nuget/artifactory"
ssm_parameter_sonar_host           = "/sonarqube/host"


artifact_version       = "1.0" ## unused variable in the module, it will be removed in the next version.
project_name           = "sample-dotnet-ccoe-1121"
project_key            = "sample-dotnet-ccoe-1121"
project_root_directory = "reference-pipelines/dotnet/ec2/quickstart-dotnetcore-cicd"
dotnet_version         = "6.0"
github_branch          = "main"

project_unit_test_dir = "" ## unused variable in the module, it will be removed in the next version.
unit_test_commands    = "dotnet test $PROJECT_UNIT_TEST_DIRECTORY -c release --logger trx --results-directory ./testresults"

project_file_location = "WebApplicationSample" ## unused variable in the module, it will be removed in the next version.
artifact_name_dotnet  = "sample-dotnet-core-1.0.0.zip"
github_repo_url       = "https://github.com/pgetech/terraform-cicd-pipeline-ref.git"


#Iam_role
codebuild_role_service    = ["codebuild.amazonaws.com"]
codetest_role_name        = "codetest_dotnet_iam_policy"
codepipeline_role_service = ["codepipeline.amazonaws.com"]

#codescan stage
environment_image_codescan      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codescan       = "LINUX_CONTAINER"
concurrent_build_limit_codescan = 1
compute_type_codescan           = "BUILD_GENERAL1_SMALL"
source_location_codescan        = "https://github.com/pgetech/terraform-cicd-pipeline-ref.git"


#codetest
environment_image_codetest      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codetest       = "LINUX_CONTAINER"
source_location_codetest        = "https://github.com/pgetech/terraform-cicd-pipeline-ref.git"
concurrent_build_limit_codetest = 1
compute_type_codetest           = "BUILD_GENERAL1_SMALL"

#codedownload
environment_image_codedownload      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_codedownload       = "LINUX_CONTAINER"
source_location_codedownload        = "https://github.com/pgetech/terraform-cicd-pipeline-ref.git"
concurrent_build_limit_codedownload = 1
compute_type_codedownload           = "BUILD_GENERAL1_SMALL"

#security_group
sg_name        = "sg_codebuild_dotnet_1121"
sg_description = "security group for codebuild project dotnet"
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
sg_name_codebuild        = "sg_codebuild_codetest_project_dotnet_1121"
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
#kms_key
kms_name        = "codebuild_key_dotnet"
kms_description = "kms key for codebuild dotnet"

#EC2
sg_name_ec2        = "ec2-sg-artifact-download"
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
    from             = 2049,
    to               = 2049,
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

ec2_name                      = "dotnet-ec2"
ssm_parameter_golden_ami_name = "/ami/linux/golden"
ec2_instance_type             = "t2.medium"
ec2_az                        = "us-west-2c"
root_block_device_volume_type = "gp3"
root_block_device_throughput  = 200
root_block_device_volume_size = 50


#codeDeploy
codedeploy_role_service = ["codedeploy.amazonaws.com"]
codedeploy_app_name     = "artifact-download-dotnet-stco"
deployment_tag_key      = "Name"
#deployment_tag_value    = "ec2-deploy-dotnet"
deployment_type   = "IN_PLACE"                #deployment type "IN_PLACE" or "BLUE_GREEN", if "BLUE_GREEN" additional configurations are required
deployment_option = "WITHOUT_TRAFFIC_CONTROL" #blocks traffic to the instance before deploying, if you do not want to block traffic try withiut "WITHOUT_TRAFFIC_CONTROL"

#download artifact
download_artifact    = true
sonar_branch_scanned = "main"
