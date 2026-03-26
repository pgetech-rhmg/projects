variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type        = string
  description = "The name of the branch that the associated Terraform configuration version was ingressed from - predefined in TFC. See https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment"
  default     = null
}

variable "aws_role" {
  # Predefined in TFC
  description = "AWS role to assume - predefined in TFC"
  type        = string
}

variable "github_secret" {
  type        = string
  description = "ASM secret name for GitHub token"
  default     = "MRAD_GITHUB_TOKEN"
}

variable "account_num" {
  # Predefined in TFC
  type        = string
  description = "Target AWS account number - predefined in TFC"
}

variable "AppID" {
  type        = number
  description = "Identify the application this asset belongs to by its AMPS APP ID. Format = APP-####"
  default     = 1795
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod"
  default     = "development"
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance 7"
  default     = "Internal"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score"
  default     = "Medium"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance.  Should be a group or list of email addresses."
  default     = ["MRAD@pge.com"]
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Lead. Note: separated by underscore giving WAF tagging limitations"
  default     = ["A1P2_S2RB_JVCW"]
}

variable "Compliance" {
  type        = list(string)
  description = "Identify assets with compliance requirements (SOX, HIPAA, NERC etc.)"
  default     = ["None"]
}

variable "Order" {
  type        = string
  description = "7 or 8 digit order number for FinOps. See https://wiki.comp.pge.com/display/SW/MRAD+FinOps+Order+Numbers"
  default     = "8193198"
}
