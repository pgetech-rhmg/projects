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


###############################################################################
# Agent Host
###############################################################################

variable "instance_type" {
  description = "EC2 instance type for the ADO scan agent. SonarQube analysis is JVM/memory-heavy; m5.large (8 GB) is the floor, m5.xlarge (16 GB) is safer for large .NET solutions."
  type        = string
  default     = "m5.large"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB. Needs headroom for the .NET SDK, SonarQube scanner cache, Node modules, and cloned repos."
  type        = number
  default     = 60
}

variable "vpc_id" {
  description = "VPC for the agent's security group. Defaults to the shared EPIC nonprod VPC (same VPC as epic-api)."
  type        = string
  default     = "vpc-8c57a5f4"
}

variable "subnet_id" {
  description = "Subnet ID for the agent. Must have outbound egress to Azure DevOps, the internal SonarQube server, Wiz, and AWS Secrets Manager. Defaults to the subnet epic-api's app server runs in (proven outbound egress to GitHub/ADO)."
  type        = string
  default     = "subnet-f9206980"
}

variable "scan_secret_arns" {
  description = "ARNs of the Secrets Manager secrets the agent may read (e.g. WIZ_CLIENT_ID/SECRET, GITHUB_PAT). Grants secretsmanager:GetSecretValue on these only."
  type        = list(string)
  default     = []
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
