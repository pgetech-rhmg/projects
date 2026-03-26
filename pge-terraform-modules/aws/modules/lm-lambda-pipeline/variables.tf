#
#  Filename    : aws/modules/lm-lambda-pipeline/variables.tf
#  Date        : 15 April 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : LAMBDA terraform module creates a Lambda Function
#
variable "lambda_name" {
  description = "Name of the lambda function"
  type        = string
  validation {
    condition     = can(regex("^lm-[A-Za-z0-9-]+$", var.lambda_name))
    error_message = "lambda_name must start with 'lm-' and can only contain letters, numbers, and hyphens"
  }
}

variable "repo_name" {
  type        = string
  description = "The name of the repository that Terraform is deploying to AWS"
  validation {
    condition     = can(regex("^lm-[A-Za-z0-9-]+$", var.repo_name))
    error_message = "repo_name must start with 'lm-' and can only contain letters, numbers, and hyphens"
  }
}

variable "github_org" {
  type        = string
  description = "The GitHub organization that owns the repository."
  default     = "PGEDigitalCatalyst"
}

variable "github_secret" {
  description = "Github secret name"
  type        = string
  default     = "system/github"
}

variable "runtime_version" {
  description = "Node.js runtime version"
  type        = string
  default     = "22"
}

variable "wiz_secret" {
  description = "WIZ cli secret name"
  type        = string
  default     = "shared-wiz-access"
}

variable "sonar_token" {
  description = "SonarQube token secret name"
  type        = string
  default     = "lm/sonarqube"
}

variable "sonar_cli_download_url" {
  description = "SonarQube CLI download URL"
  type        = string
  default     = "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip"
}

variable "codebuild_image" {
  description = "Image used inside CodeBuild. This limits the tooling you can use inside your pipeline steps. Learn more: https://docs.aws.amazon.com/codebuild/latest/userguide/available-runtimes.html"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "vpc" {
  type        = string
  description = "The name of the SSM Parameter that has the VPC id to use for each CodeBuild step."
  default     = "/vpc/id"
}

variable "subnets" {
  type        = list(string)
  description = "The name of the SSM Parameters that comtain the subnet ids to use for each CodeBuild step."
  default     = ["/vpc/privatesubnet1/id", "/vpc/privatesubnet2/id", "/vpc/privatesubnet3/id"]
}
