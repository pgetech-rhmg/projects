# Variables for Azure Subscription Vending module

# Subscription Vending Module
# Creates new Azure subscription using subscription alias API
# Configured for Enterprise Agreement (EA) billing

variable "partner_name" {
  description = "Partner name"
  type        = string
}

variable "partner_config" {
  description = "Partner configuration from YAML"
  type        = any
}

variable "billing_scope" {
  description = "EA enrollment account billing scope - Format: /providers/Microsoft.Billing/billingAccounts/{enrollmentId}/enrollmentAccounts/{accountId}"
  type        = string
}

variable "management_group_id" {
  description = "Management group ID for subscription placement"
  type        = string
}

variable "ado_project" {
  description = "Azure DevOps project name for tagging"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the subscription vending"
  type        = map(string)
  default     = {}
}