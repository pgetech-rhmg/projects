variable "app_id" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "data_classification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
  type        = string
}

variable "cris" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  type        = string
}

variable "notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  type        = list(string)
}

variable "compliance" {
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "name" {
  description = "Name of the project which will be used as a prefix for every resource."
  type        = string
  default     = "imagebuilder-rhel-arcgis-server"
}

variable "order" {
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

variable "source_bucket" {
  description = "S3 bucket containing ArcGIS installation files"
  type        = string
}

variable "share_account_ids" {
  description = "List of AWS account IDs to share AMIs with"
  type        = list(string)
  default     = []
}

variable "base_ami_name_filter" {
  description = "Name filter for base AMI (e.g., amzn2-ami-hvm-*-x86_64-gp2)"
  type        = string
  default     = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "instance_types" {
  description = "List of instance types for image builder"
  type        = list(string)
  default     = ["t3.medium"]
}

# variable "webadapter_version" {
#   description = "ArcGIS Web Adapter version"
#   type        = string
# }

# variable "portal_version" {
#   description = "ArcGIS Portal version"
#   type        = string
# }

# variable "datastore_version" {
#   description = "ArcGIS DataStore version"
#   type        = string
# }

# variable "server_version" {
#   description = "ArcGIS Server version"
#   type        = string
# }


# Pipeline variables
variable "tfc_url" {
  description = "Terraform Cloud URL"
  type        = string
  default     = "https://app.terraform.io"
}

variable "tfc_workspace_path" {
  description = "Terraform Cloud workspace path (org/workspace)"
  type        = string
}

variable "tfc_api_token_secret_id" {
  description = "Secrets Manager secret ID containing TFC API token"
  type        = string
}

# TFC dry run mode
variable "tfc_dry_run" {
  description = "Enable dry run mode for TFC runner (no actual API calls)"
  type        = bool
  default     = true
}

# Test mode - use existing AMIs instead of building new ones
variable "test_mode" {
  description = "Enable test mode to skip image builder and use existing AMIs"
  type        = bool
  default     = false
}

# Test instance configuration for dry_run mode
variable "test_subnet_id" {
  description = "Subnet ID for launching test EC2 instances in dry_run mode"
  type        = string
  default     = ""
}

variable "test_instance_type" {
  description = "Instance type for test EC2 instances in dry_run mode"
  type        = string
  default     = "t3.small"
}

variable "source_ami_id" {
  type        = string
  description = "The source AMI to base all built AMIs from"
}

variable "esri_assets_location" {
  type        = string
  description = "S3 bucket containing ESRI assets"
}

variable "webadapter_machinename" {
  type        = string
  description = "Value for Web Adapter machine name tag"
  default     = "sor-11-5-arcgis-webadaptor-sandbox"
}

variable "server_machinename" {
  type        = string
  description = "Value for ArcGIS Server machine name tag"
  default     = "sor-11-5-arcgis-hosting-sandbox"
}

variable "datastore_machinename" {
  type        = string
  description = "Value for ArcGIS DataStore machine name tag"
  default     = "sor-11-5-arcgis-datastore-sandbox"
}

variable "portal_machinename" {
  type        = string
  description = "Value for ArcGIS Portal machine name tag"
  default     = "sor-11-5-arcgis-portal-sandbox"
}
