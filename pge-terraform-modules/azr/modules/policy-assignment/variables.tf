# Policy Assignment Module
# Assigns Azure Policies for tag enforcement and compliance

variable "partner_name" {
  description = "Partner name"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID for policy assignment scope"
  type        = string
}

variable "enforcement_mode" {
  description = "Policy enforcement mode: Default or DoNotEnforce"
  type        = string
  default     = "Default"
}

variable "required_tags" {
  description = "List of required tags"
  type        = list(string)
  default     = ["AppID", "Owner", "Environment"]
}

variable "app_id" {
  description = "Application ID for tagging"
  type        = string
}