# Required variables (injected by EPIC)
variable "aws_account_id" {
  description = "AWS Account used for this resource."
  type        = string
}

variable "environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."

  validation {
    condition     = contains(["dev", "test", "qa", "prod"], var.environment)
    error_message = "Valid values for Environment are (dev, test, qa, prod). Please select on these as Environment parameter."
  }
}

# Required
variable "appid" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
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


# Optional variables (defaulted)
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
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, CCPA, BCSI or None) Note: BCSI Workloads require specific considerations"
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
