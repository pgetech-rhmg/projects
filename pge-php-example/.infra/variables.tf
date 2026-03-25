############################################
# Azure Context
############################################

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for the application"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
  default     = "westus2"
}

############################################
# Application
############################################

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "pge-php-example"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "qa", "prod"], var.environment)
    error_message = "environment must be dev, test, qa, or prod"
  }
}

############################################
# App Service
############################################

variable "service_plan_name" {
  type        = string
  description = "App Service Plan name"
}

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU"
  default     = "B1"
}

variable "runtime_version" {
  type        = string
  description = "PHP version"
  default     = "8.3"
}

############################################
# Tagging & Compliance
############################################

variable "appid" {
  type        = number
  description = "AMPS APP ID"
}

variable "notify" {
  type        = list(string)
  description = "Notification email addresses"
}

variable "owner" {
  type        = list(string)
  description = "Resource owners (exactly 3 LANIDs)"
}

variable "order" {
  type        = number
  description = "Cost tracking order number"
}

variable "dataclassification" {
  type        = string
  description = "Data classification"
  default     = "Public"
}

variable "compliance" {
  type        = list(string)
  description = "Compliance requirements"
  default     = ["None"]
}

variable "cris" {
  type        = string
  description = "Cyber Risk Impact Score"
  default     = "Low"
}
