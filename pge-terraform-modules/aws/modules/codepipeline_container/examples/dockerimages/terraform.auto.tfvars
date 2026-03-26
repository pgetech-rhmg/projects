account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

AppID       = "1001" # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment = "Dev"  # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205 #Order tag is required and must be a number between 7 and 9 digits
optional_tags = {
  Name     = "codepipeline dockerimages"
  pge_team = "ccoe-tf-developers"
}

codepipeline_name = "dockerimages-pipeline-r5vd"
repo_name         = "terraform-cicd-pipeline-ref"
github_org        = "pgetech"
branch            = "main"
app_owners        = "m7k3_ab1c"


artifact_bucket_owner_access = "FULL"
artifact_path                = "codepipeline-docker/"

# For testing this example, we need to create a Github token
# and pass the value of token through ssm parameter store.
# provide the name of that parameter in the variable "parameter_name"

secretsmanager_github_token_secret_name = "github_token_r5vd:pat"

ssm_parameter_vpc_id                      = "/vpc/id"
ssm_parameter_subnet_id1                  = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2                  = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3                  = "/vpc/2/privatesubnet3/id"
ssm_parameter_artifactory_host            = "/jfrog/url"
ssm_parameter_artifactory_docker_registry = "/jfrog/ccoe-cicd/docker-registry"

secretsmanager_artifactory_token = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user  = "jfrog_credentials:jfrog_user"


secretsmanager_wiz_client_secret = "shared-wiz-access:WIZ_CLIENT_SECRET"
secretsmanager_wiz_client_id     = "shared-wiz-access:WIZ_CLIENT_ID"


#Iam_role
codebuild_role_service    = ["codebuild.amazonaws.com"]
codepipeline_role_service = ["codepipeline.amazonaws.com"]


#codebuild stage 
environment_image_codebuild      = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
environment_type_codebuild       = "LINUX_CONTAINER"
source_location_codebuild        = "https://github.com/pgetech/terraform-cicd-pipeline-ref"
concurrent_build_limit_codebuild = 2
compute_type_codebuild           = "BUILD_GENERAL1_LARGE"

#security_group
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

DockerImage_name = "alpine-test-pipeline"

######################### SNS ###############################
endpoint_email = [] # Endpoint to send data to. The contents vary with the protocol.

