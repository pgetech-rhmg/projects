variable "account_num" {
  description = "The AWS account number where resources will be created."
  type        = string
  default     = "064160142714"
}

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-west-2"
}

variable "aws_role" {
  description = "The AWS IAM role to assume for resource creation."
  type        = string
  default     = "CloudAdmin"
}
variable "runtime_name" {
  description = "The name prefix for resources."
  type        = string
  default     = "ccoe_bedrock_agent"
}

variable "runtime_module_source" {
  description = "The source path for the Bedrock Agent Runtime module."
  type        = string
  default     = "../../modules/runtime/"
}

variable "runtime_container_uri" {
  description = "The URI of the container image for the Bedrock Agent Runtime."
  type        = string
  default     = "064160142714.dkr.ecr.us-west-2.amazonaws.com/bedrock/agent-runtime-76ab0c91:latest"
}

# Runtime module variables
variable "create_runtime" {
  description = "Whether to create the Bedrock Agent Runtime."
  type        = bool
  default     = true
}

variable "runtime_description" {
  description = "Description for the Bedrock Agent Runtime."
  type        = string
  default     = "Bedrock Agent Runtime"
}

variable "runtime_artifact_type" {
  description = "The artifact type for the runtime (container or code)."
  type        = string
  default     = "container"
}

variable "runtime_environment_variables" {
  description = "Environment variables for the runtime."
  type        = map(string)
  default     = {}
}

variable "runtime_tags" {
  description = "Tags for the runtime."
  type        = map(string)
  default     = {}
}

variable "runtime_code_runtime_type" {
  description = "The runtime type for code-based runtimes."
  type        = string
  default     = "PYTHON_3_13"
}

# Runtime endpoint variables
variable "create_runtime_endpoint" {
  description = "Whether to create the runtime endpoint."
  type        = bool
  default     = true
}

variable "runtime_endpoint_name" {
  description = "Name for the runtime endpoint."
  type        = string
  default     = "bedrock-runtime-endpoint"
}

variable "runtime_endpoint_description" {
  description = "Description for the runtime endpoint."
  type        = string
  default     = "Bedrock Agent Runtime Endpoint"
}

variable "runtime_endpoint_tags" {
  description = "Tags for the runtime endpoint."
  type        = map(string)
  default     = {}
}

# Memory module variables
variable "create_memory" {
  description = "Whether to create memory for the agent."
  type        = bool
  default     = false
}

variable "memory_name" {
  description = "Name for the memory resource."
  type        = string
  default     = ""
}

variable "memory_description" {
  description = "Description for the memory resource."
  type        = string
  default     = ""
}

variable "memory_type" {
  description = "Type of memory (DYNAMODB)."
  type        = string
  default     = "DYNAMODB"
}

variable "memory_dynamodb_table_name" {
  description = "DynamoDB table name for memory."
  type        = string
  default     = ""
}

variable "memory_dynamodb_read_capacity_units" {
  description = "Read capacity units for DynamoDB."
  type        = number
  default     = 5
}

variable "memory_dynamodb_write_capacity_units" {
  description = "Write capacity units for DynamoDB."
  type        = number
  default     = 5
}

variable "memory_tags" {
  description = "Tags for memory resources."
  type        = map(string)
  default     = {}
}

# Variables for aws_ssm_parameter
variable "parameter_vpc_id_name" {
  type        = string
  description = "Id of vpc stored in aws_ssm_parameter"
  default     = ""
}

variable "parameter_subnet_id1_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = ""
}

variable "parameter_subnet_id2_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = ""
}

variable "parameter_subnet_id3_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
}

variable "ci_logs_bucket_name" {
  description = "The name of the S3 bucket to store CodeBuild logs."
  type        = string
  default     = "pge-bedrock-agent-ci-logs-bucket"
}
variable "ci_github_secret" {
  description = "The name of the AWS Secrets Manager secret containing the GitHub token."
  type        = string
}
variable "ci_branch" {
  description = "The git branch to build."
  type        = string
  default     = "main"
}

variable "ci_image" {
  description = "The AWS CodeBuild image to use for CI builds."
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}
variable "ci_compute_type" {
  description = "The AWS CodeBuild compute type to use for CI builds."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "repo_url" {
  description = "The URL of the Git repository for the CodeBuild project."
  type        = string
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Order" {
  type        = number
  description = "Order as a tag to be associated with an AWS resource"
}

variable "agent_foundation_model" {
  description = "The foundation model to use for the Bedrock Agent."
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "kms_key" {
  description = "The ARN of the KMS key"
  type        = string
  default     = null
}