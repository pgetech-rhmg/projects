###############################################################################
# Organization & Account
###############################################################################

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod, etc.)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "org_id" {
  description = "AWS Organizations ID for PGE"
  type        = string
}


###############################################################################
# Tagging & Compliance
###############################################################################

variable "appid" {
  description = "Identify the application this asset belongs to by its AMPS APP ID. Format = APP-####"
  type        = number
}

variable "notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."

  validation {
    condition = alltrue([
      for aliases in var.notify : can(regex("^\\w+([\\.!-/:[-`{-~]?\\w+)*@([\\.-]?\\w+)*(\\.\\w{2,3})+$", aliases))
    ])
    error_message = "Invalid Email Address for Notify tag."
  }
}

variable "owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"

  validation {
    condition     = length(var.owner) == 3
    error_message = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg."
  }
}

variable "order" {
  type        = number
  description = "Order as a tag to be associated with an AWS resource"

  validation {
    condition     = var.order >= 1000000 && var.order <= 999999999
    error_message = "Order must be a number between 7 and 9 digits"
  }
}

variable "dataclassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, Restricted-BCSI (only one)"
  default     = "Internal"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted", "Privileged", "Confidential-BCSI", "Restricted-BCSI"], var.dataclassification)
    error_message = "Valid values for DataClassification are (Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, Restricted-BCSI). Please select on these as DataClassification parameter."
  }
}

variable "compliance" {
  type        = list(string)
  description = "Compliance Identify assets with compliance requirements (SOX, HIPAA, CCPA, BCSI or None) Note: BCSI Workloads require specific considerations"
  default     = ["None"]

  validation {
    condition = alltrue([
      for alias in var.compliance : contains(["SOX", "HIPAA", "CCPA", "BCSI", "None"], alias)
    ])
    error_message = "Valid values for DataClassification are SOX, HIPAA, CCPA, BCSI or None. Please select on these as Compliance parameter."
  }
}

variable "cris" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  default     = "Low"

  validation {
    condition     = contains(["High", "Medium", "Low"], var.cris)
    error_message = "Valid values for Cyber Risk Impact Score are High, Medium, Low (only one). Please select one these CRIS values."
  }
}


###############################################################################
# Configuration
###############################################################################

variable "custom_bucket_name" {
  description = "Globally-unique S3 bucket name that hosts the epic-compliance CLI binary artifacts."
  type        = string
  default     = "pge-epic-compliance-reviewer"
}

variable "access_log_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "enable_access_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = false
}

variable "deployment_role_name" {
  description = "Name of the cross-account EPIC deployment role that publishes/reads artifacts."
  type        = string
  default     = "pge-epic-deployment-role"
}

variable "reader_role_arns" {
  description = <<EOT
Additional IAM role ARNs granted read (GetObject/ListBucket) on the artifact
bucket — e.g. the EPIC scan-agent's instance role, so the pipeline stage can
pull the binary. Deployment roles across the org are always allowed; these are
extra principals in the local account.
EOT
  type        = list(string)
  default     = []
}


###############################################################################
# Artifact Upload
#
# When artifact_source is set, Terraform uploads the compiled linux/amd64 binary
# to the bucket at artifact_key. Leave artifact_source empty to manage the
# bucket only and publish binaries out-of-band (e.g. from CI via aws s3 cp).
###############################################################################

variable "artifact_source" {
  description = "Local path to the compiled epic-compliance linux/amd64 binary to upload. Empty = do not upload from Terraform."
  type        = string
  default     = ""
}

variable "artifact_key" {
  description = "S3 object key for the uploaded binary. Pin the version (never 'latest'), e.g. compliance/epic-compliance-v1.0.0-linux-amd64."
  type        = string
  default     = ""
}
