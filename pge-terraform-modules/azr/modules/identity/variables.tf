# Variables for Managed Identity
# Identity Module
# Creates Managed Identity with federated credentials for TFC and GitHub

variable "partner_name" {
  description = "Partner name"
  type        = string
}

variable "partner_config" {
  description = "Partner configuration from YAML"
  type        = any
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID for RBAC assignments"
  type        = string
}

variable "tfc_organization" {
  description = "Terraform Cloud organization name"
  type        = string
}

variable "tfc_workspace_name" {
  description = "Terraform Cloud workspace name"
  type        = string
}

variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# NOTE: Azure DevOps federated credential is created in WS2 (ado-automation)
# after the service connection is created, since the subject is only known then.
# See: terraform/ado-automation/modules/azuredevops-service-connections/main.tf