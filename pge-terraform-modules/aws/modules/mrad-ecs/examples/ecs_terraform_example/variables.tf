#tflint-ignore: terraform_naming_convention
variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type        = string
  description = "Injected by Terraform Cloud. The git branch name for the current configuration version."
  default     = "development"
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume for r53"
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number, mandatory for r53"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_account" {
  type        = string
  description = "The aws account/environment (Dev/Test/QA/Prod)"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "github_secret" {
  type        = string
  description = "GitHub webhook secret for CodePipeline source."
}

variable "swap_cert_arns" {
  type        = map(string)
  description = "ARN of swapdev/qa/prd"
  default = {
    "Dev" = "arn:aws:acm:us-west-2:990878119577:certificate/e6b04cdf-2d36-40f4-8a55-7f0d7ba94678"
  }
}