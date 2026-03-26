variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "aws_r53_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
  default     = "CloudAdmin"
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume"
  default     = "CloudAdmin"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number, mandatory"
  default     = "514712703977"
}

variable "api_type" {
  type        = string
  description = "API Type. Internal or Public"

  validation {
    condition     = contains(["Internal", "Public"], var.api_type)
    error_message = "Valid values for API Type are (Internal, Public). Please select on these as API Type parameter."
  }
} 

variable "sub_domain_name" {
  type        = string
  description = "Sub Domain Name. Dev and Test use nonprod. QA and Prod use ss"

  validation {
    condition     = contains(["nonprod", "ss"], var.sub_domain_name)
    error_message = "Valid values for Sub Domain Name are (nonprod, ss). Please select on these as Sub Domain parameter."
  }
}

variable "api_id" {
  description = "Name of the API ID"
  type        = string
}

variable "api_stage" {
  description = "Stage of the API"
  type        = string
}

########################################################
########### Tags #######################################
########################################################
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."

  validation {
    condition     = contains(["Dev", "Test", "QA", "Prod"], var.Environment)
    error_message = "Valid values for Environment are (Dev, Test, QA, Prod). Please select on these as Environment parameter."
  }
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted", "Privileged"], var.DataClassification)
    error_message = "Valid values for DataClassification are (Public, Internal, Confidential, Restricted, Privileged). Please select on these as DataClassification parameter."
  }
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"

  validation {
    condition = alltrue([
    for alias in var.Compliance : contains(["SOX", "HIPAA", "CCPA", "None"], alias)
    ])
    error_message = "Valid values for DataClassification are SOX, HIPAA, CCPA or None. Please select on these as Compliance parameter."
  }
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"

  validation {
    condition     = contains(["High", "Medium", "Low"], var.CRIS)
    error_message = "Valid values for Cyber Risk Impact Score are High, Medium, Low (only one). Please select one these CRIS values."
  }
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."

  validation {
    condition = alltrue([
    for aliases in var.Notify : can(regex("^\\w+([\\.-]?\\w+)*@([\\.-]?\\w+)*(\\.\\w{2,3})+$", aliases))
    ])
    error_message = "Invalid Email Address for Notify tag."
  }

}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  validation {
    condition     = length(var.Owner) == 3
    error_message = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg."
  }
}

############################