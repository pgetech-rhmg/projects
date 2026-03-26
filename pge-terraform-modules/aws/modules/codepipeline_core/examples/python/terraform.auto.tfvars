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
  Name = "test"
  # pge_team = "ccoe-tf-developers"
}

codepipeline_name = "python-r5vd"

github_org   = "pgetech"
repo_name    = "terraform-cicd-pipeline-ref"
branch       = "MounikaKota9-pytest"
project_key  = "codepipeline-python-ccoe-1121"
project_name = "codepipeline-python-ccoe-1121"

bucket_name                  = "codepipeline-bucket-python-m7k3"
artifact_bucket_owner_access = "FULL"
artifact_path                = "codepipeline-new/"

ssm_parameter_vpc_id                = "/vpc/id"
ssm_parameter_subnet_id1            = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2            = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3            = "/vpc/2/privatesubnet3/id"
ssm_parameter_artifactory_host      = "/jfrog/host"
ssm_parameter_artifactory_repo_name = "/jfrog/pypi/artifactory"
ssm_parameter_sonar_host            = "/sonarqube/host"
secretsmanager_artifactory_token    = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user     = "jfrog_credentials:jfrog_user"
secretsmanager_sonar_token          = "sonarqube_credentials:sonar_token"

# For testing this example, we need to create a Github token
# and pass the value of token through ssm parameter store.
# provide the name of that parameter in the variable "token"
# warning appears in the console during "terraform apply" is due to using GitHub Version 1 since codesta ARN provided has some functional issues GitHub Version 1 is used.

secretsmanager_github_token_secret_name = "github_token_stco:pat"

project_root_directory    = "reference-pipelines/python/ec2/python_django_webapp" #provide-project-root-directory-here, leave it empty if code is on root folder
github_repo_url           = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
dependency_files_location = ""                                                                                                                                                   #provide-dependency-files-location-here, leave it empty if there are no dependencies
unit_test_commands        = "pip install pysqlite3 && pip install pysqlite3-binary && python -m coverage run -m unittest && python -m coverage report && python -m coverage xml" #provide-unit-test-commands-here"
python_runtime            = "3.9"                                                                                                                                                ##update with your python run time to compile your code
#Iam_role
codebuild_role_service         = ["codebuild.amazonaws.com"]
codetest_role_name             = "codetest_python_iam_policy_stco"
codepipeline_role_service      = ["codepipeline.amazonaws.com"]
custom_codebuild_policy_file   = "custom_codebuild_file.json"
custom_codescan_policy_file    = "custom_codescan_file.json"
custom_codepublish_policy_file = "custom_codepublish_file.json"
#codebuild stage
environment_image_codebuild      = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
environment_type_codebuild       = "LINUX_CONTAINER"
source_location_codebuild        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codebuild = 1
compute_type_codebuild           = "BUILD_GENERAL1_SMALL"
#codescan stage
environment_image_codescan      = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
environment_type_codescan       = "LINUX_CONTAINER"
concurrent_build_limit_codescan = 1
compute_type_codescan           = "BUILD_GENERAL1_SMALL"
#codepublish stage
environment_image_codepublish      = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
environment_type_codepublish       = "LINUX_CONTAINER"
concurrent_build_limit_codepublish = 1
compute_type_codepublish           = "BUILD_GENERAL1_SMALL"
#codetest
environment_image_codetest      = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
environment_type_codetest       = "LINUX_CONTAINER"
concurrent_build_limit_codetest = 1
compute_type_codetest           = "BUILD_GENERAL1_SMALL"
#security_group
sg_name        = "sg_codebuild_project_python_1121"
sg_description = "security group for codebuild project python"
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
sg_name_codebuild        = "sg_codebuild_codetest_project_1121"
sg_description_codebuild = "security group for codebuild - codetest project python"
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
kms_name        = "codebuild_key_python_1121"
kms_description = "kms key for codebuild python"

#EC2
sg_name_ec2        = "ec2-sg-python-1121"
sg_description_ec2 = "Security group for example usage with Ec2 instance"

cidr_ingress_rules_ec2 = [{
  from             = 443,
  to               = 443,
  protocol         = "tcp",
  cidr_blocks      = ["10.0.0.0/8"]
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

ec2_name                      = "ec2-python-deploy-1121"
ssm_parameter_golden_ami_name = "/ami/linux/golden"
ec2_instance_type             = "t2.micro"
ec2_az                        = "us-west-2c"
root_block_device_volume_type = "gp3"
root_block_device_throughput  = 200
root_block_device_volume_size = 50
metadata_http_endpoint        = "enabled"

#codeDeploy
codedeploy_role_service = ["codedeploy.amazonaws.com"]
codedeploy_app_name     = "codepipeline-python-1121"
deployment_tag_key      = "Name"
deployment_tag_value    = "ec2-python-deploy-1121"
deployment_type         = "IN_PLACE"
