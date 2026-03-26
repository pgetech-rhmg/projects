variable "account_num" {
  # Predefined in TFC
  type        = string
  description = "Target AWS account number - predefined in TFC"
}

variable "aws_role" {
  # Predefined in TFC
  description = "AWS role to assume - predefined in TFC"
  type        = string
}

variable "github_token" {
  description = "GitHub token used for API access"
  type        = string
  default     = "MRAD_GITHUB_TOKEN"
}

variable "github_secret" {
  type        = string
  description = "ASM secret name for GitHub token"
  default     = "MRAD_GITHUB_TOKEN"
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number for Route 53 DNS resources"
  default = ""
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume for managing Route 53 DNS resources"
  default = ""
}
