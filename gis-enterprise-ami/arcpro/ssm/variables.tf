variable "account_num" {
  description = "Target AWS account number, mandatory. "
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

####################################################
# Variables for Tags
####################################################

#Variables forTag
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}


variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "optional_tags" {
  description = "optional_tags."
  type        = map(string)
  default     = {}
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}
### SSM Document


variable "ssm_arcpro_install_document_name" {
  type        = string
  description = "SSM document name"
}

variable "ssm_arcpro_patch_install_document_name" {
  type        = string
  description = "SSM document name"
}

variable "ssm_document_type" {
  type        = string
  description = "The type of the document. Valid document types include: Automation, Command, Package, Policy, and Session"
}

variable "ssm_document_format" {
  type        = string
  description = "The format of the document. Valid document types include: JSON and YAML"
  validation {
    condition = anytrue([
      var.ssm_document_format == "JSON",
    var.ssm_document_format == "YAML"])
    error_message = "Valid values for ssm_document_format are JSON and YAML."
  }
}

variable "arcgis_pro_license_file" {
  type        = string
  description = "The path to the ArcGIS Pro license file."
}

variable "portal_license_url" {
  type        = string
  description = "The URL to the ArcGIS Portal license file."
}

variable "portal_list" {
  type        = string
  description = "The list of ArcGIS Portal URLs."
}
