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


optional_tags = {
  Name     = "Container pipeline"
  pge_team = "ccoe-tf-developers"
}

codepipeline_name = "springpetclinic-aicg-eks"
repo_name         = "pge-java-spring-petclinic"
branch            = "e6bo-patch-1"
pollchanges       = false
artifact_path     = "codepipeline-new/"

# For testing this example, we need to create a Github token
# and pass the value of token through ssm parameter store.
# provide the name of that parameter in the variable "parameter_name"

secretsmanager_github_token_secret_name = "github_token_m7k3:pat"
github_org                              = "pgetech"
ssm_parameter_vpc_id                    = "/vpc/id"
ssm_parameter_subnet_id1                = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2                = "/vpc/2/privatesubnet3/id"

ssm_parameter_artifactory_host = "/jfrog/url"


secretsmanager_artifactory_token = "jfrog_credentials:jfrog_token"
secretsmanager_artifactory_user  = "jfrog_credentials:jfrog_user"

project_root_directory = "" #leave it empty if your source code is on root directory
java_runtime           = "corretto17"

#helmchart deploy
environment_image_helmchart      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
environment_type_helmchart       = "LINUX_CONTAINER"
source_location_helmchart        = "https://github.com/pgetech/pge-java-spring-petclinic"
concurrent_build_limit_helmchart = 2
compute_type_helmchart           = "BUILD_GENERAL1_LARGE"

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

#Rolback deployment paramters if services is deployed using helmchart packages

notification_message = "Hi, Please approve rollback request for the Spring Petclinic Application"

##EKS cluster details
eks_cluster_name = "node-12"
chart_revision   = "3"
namespace        = "petclinic-app"
container_name   = "spring-petclinic"

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
