#
# Filename    : modules/mrad-sumo/variables.tf
# Date        : 10 June 2023
# Author      : MRAD (mrad@pge.com)
# Description : variables for the mrad sumo module
#
variable "aws_account" {
  type        = string
  description = "Aws account name, dev, qa, test, production. "
}

variable "optional_tags" {
  description = "Optional_tags."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

variable "log_group_name" {
  type        = string
  description = "The name of the log group feeding Sumo"
}

variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type = string
}

variable "aws_role" {
  type = string
}

variable "partner" {
  type        = string
  description = "partner team name"
  default     = "MRAD"
}

variable "account_num" {
  # Predefined in TFC
  type        = string
  description = "Target AWS account number - predefined in TFC"
  default     = null
}

variable "http_source_name" {
  description = "Name for the Sumo Logic HTTP source."
  type        = string
  default     = "ignored" # for compatibility with older versions
}

variable "filter_pattern" {
  description = "Filter pattern for logs."
  type        = string
  default     = "" # default to empty string (all logs)
}

variable "disambiguator" {
  description = "Disambiguator for resource naming."
  type        = string
  default     = "ignored" # for compatibility with older versions (only 1 lambda now)
}
