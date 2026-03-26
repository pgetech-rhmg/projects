variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type    = string
  default = "development"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "aws_account" {
  type        = string
  description = "The aws account/environment (Dev/Test/QA/Prod)"
}

variable "github_secret" {
  type        = string
  description = "The name of the AWS Secrets Manager secret containing the GitHub Personal Access Token"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "codebuild_image" {
  description = "Docker image used inside CodeBuild. This limits the tooling you can use inside your pipeline steps. Learn more: https://docs.aws.amazon.com/codebuild/latest/userguide/available-runtimes.html"
  type        = string
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number, mandatory for r53"
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume for r53"
}
