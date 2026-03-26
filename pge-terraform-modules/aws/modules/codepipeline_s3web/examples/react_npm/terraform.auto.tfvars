account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"
build_args1 = "development"

AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order tag is required and must be a number between 7 and 9 digits

optional_tags = {
  Name     = "test"
  pge_team = "ccoe-tf-developers"
}

codepipeline_name = "codepipeline-s3web-react-ccoe-stco"

s3_static_web_bucket_name      = "dev2-s3-static-web"
aws_cloudfront_distribution_id = "EMAKDCNP0MK48"

secretsmanager_github_token_secret_name = "github_token_r5vd:pat"

ssm_parameter_vpc_id           = "/vpc/id"
ssm_parameter_subnet_id1       = "/vpc/privatesubnet1/id"
ssm_parameter_subnet_id2       = "/vpc/privatesubnet2/id"
ssm_parameter_subnet_id3       = "/vpc/privatesubnet3/id"
ssm_parameter_artifactory_host = "/jfrog/host"

ssm_parameter_sonar_host           = "/sonarqube/host"
ssm_parameter_artifactory_repo_key = "/jfrog/artifactory/ccoe_npm_repo_key"
secretsmanager_artifactory_token   = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user    = "jfrog_credentials:jfrog_user"
secretsmanager_sonar_token         = "sonarqube_credentials:sonar_token"

#Buildspec_spec environment values
project_name           = "s3web-react-npm"
project_unit_test_dir  = "provide-project-unit-test-dir-here"
project_root_directory = "reference-pipelines/s3web/react_npm"
project_key            = "s3web-react-npm"

nodejs_version          = "18"
nodejs_version_codescan = "20"
package_manager         = "npm"
github_repo_url         = "https://github.com/pgetech/terraform-cicd-pipeline-ref.git"
github_branch           = "main"

#security_group
sg_name        = "codepipeline-s3web-react-sg"
sg_description = "security group for codebuild project s3web-react"
cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]

#kms_key
kms_name        = "codepipeline-s3web-react"
kms_description = "kms key for codebuild s3web-react"

