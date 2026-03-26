#
# Filename    : modules/lm-tags/variables.tf
# Date        : 28 Feb 2025
# Author      : Sean Fairchild (s3ff@pge.com)
# Description : This terraform module applies mandatory tags to Locate & Mark the resources.
#

variable "appid" {
  description = "Override for tag value appid"
  type        = string
  default     = "/lm/common_tags/appid"
}

variable "cris" {
  description = "Override for tag value cris"
  type        = string
  default     = "/lm/common_tags/cris"
}

variable "compliance" {
  description = "Override for tag value compliance"
  type        = string
  default     = "/lm/common_tags/compliance"
}

variable "dataclassification" {
  description = "Override for tag value dataclassification"
  type        = string
  default     = "/lm/common_tags/dataclassification"
}

variable "environment" {
  description = "Override for tag value environment"
  type        = string
  default     = "/lm/common_tags/environment"
}

variable "notify" {
  description = "Override for tag value notify"
  type        = string
  default     = "/lm/common_tags/notify"
}

variable "owner" {
  description = "Override for tag value owner"
  type        = string
  default     = "/lm/common_tags/owner"
}

variable "order" {
  description = "Override for tag value owner"
  type        = string
  default     = "/lm/common_tags/order"
}
