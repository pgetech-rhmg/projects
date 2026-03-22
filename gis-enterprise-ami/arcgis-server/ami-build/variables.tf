# tags
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  type        = string
}

variable "Notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "Owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "name" {
  description = "Name of the project which will be used as a prefix for every resource."
  type        = string
  default     = "imagebuilder-rhel-arcgis-server"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

# Software Sources
variable "arcgis_version" {
  description = "ArcGIS Server version"
  type        = string
  default     = "11.5"
}

variable "tomcat_version" {
  description = "Tomcat version"
  type        = string
  default     = "9.0.106"
}


# Installation Path Configuration
variable "installer_directory_linux" {
  description = "Installer directory for ArcGIS Server on Linux"
  type        = string
  default     = "/opt/software/esri"
}

variable "install_directory_linux" {
  description = "Installation directory for ArcGIS Server on Linux"
  type        = string
  default     = "/opt/arcgis"
}

variable "supported_os_versions_linux" {
  description = "Supported Linux OS versions for the component"
  type        = list(string)
  default     = ["Red Hat Enterprise Linux 9", "Red Hat Enterprise Linux"]
}

### SSM Document
variable "ssm_server_document_name" {
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
