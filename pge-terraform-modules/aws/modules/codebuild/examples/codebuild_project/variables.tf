variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

#variables for kms_key
variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

#variables for aws_iam_role
variable "role_name" {
  description = "Name of the iam role"
  type        = string
}

variable "role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

#varibales for the module codebuild_project
variable "codebuild_project_name" {
  description = "The name of Project"
  type        = string
}

variable "codebuild_project_description" {
  description = "Short description of the project"
  type        = string
}

variable "concurrent_build_limit" {
  description = "Maximum number of concurrent builds for the project"
  type        = number
}

variable "artifact_type" {
  description = "Build output artifact's type"
  type        = string
}

variable "cache_type" {
  description = "Type of storage that will be used for the AWS CodeBuild project cache"
  type        = string
}

variable "compute_type" {
  description = "Information about the compute resources the build project will use"
  type        = string
}

variable "environment_image" {
  description = "Docker image to use for this build project"
  type        = string
}

variable "environment_type" {
  description = "Type of build environment to use for related builds"
  type        = string
}

variable "image_pull_credentials_type" {
  description = "Type of credentials AWS CodeBuild uses to pull images in your build"
  type        = string
}

variable "cloudwatch_logs_group_name" {
  description = "Name of the S3 bucket and the path prefix for S3 logs"
  type        = string
}

variable "cloudwatch_logs_stream_name" {
  description = "Name of the S3 bucket and the path prefix for S3 logs"
  type        = string
}

variable "source_git_clone_depth" {
  description = "Truncate git history to this many commits"
  type        = number
}

variable "s3_logs_status" {
  description = "Current status of logs in S3 for a build project"
  type        = string
}

variable "source_type" {
  description = "Type of repository that contains the source code to be built"
  type        = string
}

variable "source_location" {
  description = "Location of the source code from git or s3"
  type        = string
}

variable "source_fetch_sub" {
  description = "Whether to fetch Git submodules for the AWS CodeBuild build project"
  type        = bool
}

#variables for github_webhook
variable "github_base_url" {
  description = "GitHub target API endpoint"
  type        = string
}

variable "github_repository" {
  description = "The repository of the webhook"
  type        = string
}

variable "github_events" {
  description = "Indicate if the webhook should receive events"
  type        = list(string)
}

variable "github_content_type" {
  description = "The content type for the payload"
  type        = string
}

#variable for data template_file codebuild_project_policy
variable "policy_file_name" {
  description = "Valid JSON document representing a resource policy"
  type        = string
}

#variables for security_group_project
variable "cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "sg_name" {
  description = "name of the security group"
  type        = string
}

variable "sg_description" {
  description = "vpc id for security group"
  type        = string
}

#variable for S3-bucket
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

#variables for Tags
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

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "secretsmanager_github_token_secret_arn" {
  description = "ARN of the GitHub Secrets Manager containing the OAUTH or PAT"
  type        = string
}

