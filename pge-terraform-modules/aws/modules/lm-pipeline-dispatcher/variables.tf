##################################################################
#
#  Filename    : aws/modules/lm-pipeline-dispatch/variables.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Codebuild dispatcher instance that can manage deployments of multiple services in the same repository
#
##################################################################
variable "github_org" {
  type        = string
  description = "The GitHub organization that owns the repository."
  default     = "PGEDigitalCatalyst"
}

variable "repo_name" {
  type        = string
  description = "The name of the GitHub repo to use for this pipeline."
}

variable "github_secret" {
  description = "Github secret name"
  type        = string
  default     = "system/github"
}

variable "compute_type" {
  description = "The AWS CodeBuild Lambda compute type to use for CI builds. See: https://docs.aws.amazon.com/codebuild/latest/APIReference/API_ProjectEnvironment.html"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "The AWS CodeBuild Lambda image to use for CI builds. See: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html#lambda-compute-images"
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
