aws_region  = "us-west-2"
account_num = "750713712981"
aws_role    = "CloudAdmin"

# Tag variables

AppID              = "1001"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["abc1", "def2", "ghi3"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Order              = 8115205                                          #Order must be between 7 and 9 digits
Compliance         = ["None"]

# Variables for Amplify Resources

name = "tf-amplify-module-example"

auto_branch_creation_patterns = [
  "*",
  "*/**",
]

environment_variables = {
  ENV = "test"
}

custom_rule = ({
  condition = null
  source    = "/<*>"
  status    = "404"
  target    = "/index.html"
})

github_repository_name = "test-a4jf-amplify-2"

enable_branch_auto_build = true
# Enables auto build for the created branch.

enable_auto_branch_creation = true

build_spec                        = null
enable_auto_build                 = true
enable_performance_mode           = null
enable_pull_request_preview       = null
auto_branch_environment_variables = { "ENV" = "dev" }
auto_branch_framework             = null
pull_request_environment_name     = null
stage                             = "DEVELOPMENT"

# Variables for IAM Role

role_service    = ["amplify.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess-Amplify"]

# Variables for  secrets manager

secretsmanager_github_access_token_secret_name = "github_token_aicg_key_value:rb1c"
secretsmanager_basic_auth_cred_secret_name     = "basic_auth_cred:e6bo"

# Variables for branch and backend environment

framework = "React"

main_branch_name = "main"
dev_branch_name  = "dev"
qa_branch_name   = "qa"
test_branch_name = "test"

main_stage = "PRODUCTION"
dev_stage  = "DEVELOPMENT"
qa_stage   = "BETA"
test_stage = "EXPERIMENTAL"

# Variables for Amplify Domain Association

amplify_domain_wait_for_verification = false

domain_name_prod     = "ss.pge.com"
domain_name_non_prod = "nonprod.pge.com"

sub_domain_prefix_main = "main"
sub_domain_prefix_dev  = "dev"
sub_domain_prefix_qa   = "qa"
sub_domain_prefix_test = "test"