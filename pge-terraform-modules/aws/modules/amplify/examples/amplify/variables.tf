# Variables for provider

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

# Variables for tags

variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  type        = string
}

variable "Notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "Owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}


# Variables for Common Resources

variable "name" {
  description = "The name you assign to the amplify resources. It must be unique in your account."
  type        = string
}

# Variables for Amplify App

variable "github_repository_name" {
  description = "Repository for an Amplify app. The github repository should be created under PGE organization."
  type        = string
}

variable "enable_branch_auto_build" {
  description = "Enables auto-building of branches for the Amplify App."
  type        = bool
}

variable "auto_branch_creation_patterns" {
  description = "Automated branch creation glob patterns for an Amplify app."
  type        = list(string)
}

variable "environment_variables" {
  description = "Environment variables map for an Amplify app."
  type        = map(string)
}

variable "enable_auto_branch_creation" {
  description = "Enables automated branch creation for an Amplify app."
  type        = bool
}

variable "build_spec" {
  description = "Build specification (build spec) for the autocreated branch"
  type        = string
}

variable "enable_auto_build" {
  description = "Enables auto building for the autocreated branch."
  type        = bool
}

variable "enable_performance_mode" {
  description = "Enables performance mode for the branch."
  type        = bool
}

variable "enable_pull_request_preview" {
  description = "Enables pull request previews for the autocreated branch."
  type        = bool
}

variable "auto_branch_environment_variables" {
  description = "Environment variables for the autocreated branch."
  type        = map(string)
}

variable "auto_branch_framework" {
  description = "Framework for the autocreated branch."
  type        = string
}

variable "pull_request_environment_name" {
  description = "Amplify environment name for the pull request."
  type        = string
}

variable "stage" {
  description = "Describes the current stage for the autocreated branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST."
  type        = string
}

variable "custom_rule" {
  description = <<-_EOT
  Custom rewrite and redirect rules for an Amplify app.
  {
   condition : Condition for a URL rewrite or redirect rule, such as a country code.
   source    : Source pattern for a URL rewrite or redirect rule.
   status    : Status code for a URL rewrite or redirect rule. Valid values: 200, 301, 302, 404, 404-200.
   target    : Target pattern for a URL rewrite or redirect rule.
  }
  _EOT
  type = object({
    condition = string
    source    = string
    status    = string
    target    = string
  })
}

# Variables for IAM

variable "role_service" {
  description = "Aws service for the IAM role."
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the IAM role."
  type        = list(string)
}

# Variables for Secrets manager

variable "secretsmanager_github_access_token_secret_name" {
  description = "Enter the name of secrets manager for amplify personal access token."
  type        = string
}

variable "secretsmanager_basic_auth_cred_secret_name" {
  description = "Enter the name of secrets manager for basic auth crentials"
  type        = string
}

#variables for branch and backend environment
variable "framework" {
  description = "Framework for the branch."
  type        = string
}

variable "main_branch_name" {
  description = " Name for the branch."
  type        = string
}

variable "dev_branch_name" {
  description = " Name for the branch."
  type        = string
}

variable "qa_branch_name" {
  description = " Name for the branch."
  type        = string
}

variable "test_branch_name" {
  description = " Name for the branch."
  type        = string
}

variable "main_stage" {
  description = "Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST."
  type        = string
}

variable "dev_stage" {
  description = "Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST."
  type        = string
}

variable "qa_stage" {
  description = "Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST."
  type        = string
}

variable "test_stage" {
  description = "Describes the current stage for the branch. Valid values: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST."
  type        = string
}

# Variables for Amplify domain association

variable "amplify_domain_wait_for_verification" {
  description = "If enabled, the resource will wait for the domain association status to change to PENDING_DEPLOYMENT or AVAILABLE. Setting this to false will skip the process. Default: true."
  type        = bool
}

variable "domain_name_prod" {
  description = "Domain name for the domain association."
  type        = string
}

variable "domain_name_non_prod" {
  description = "Domain name for the domain association."
  type        = string
}

variable "sub_domain_prefix_main" {
  description = "Prefix setting for the subdomain."
  type        = string
}

variable "sub_domain_prefix_dev" {
  description = "Prefix setting for the subdomain."
  type        = string
}

variable "sub_domain_prefix_qa" {
  description = "Prefix setting for the subdomain."
  type        = string
}

variable "sub_domain_prefix_test" {
  description = "Prefix setting for the subdomain."
  type        = string
}