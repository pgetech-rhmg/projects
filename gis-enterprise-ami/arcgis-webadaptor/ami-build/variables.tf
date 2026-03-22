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
  default     = "imagebuilder-rhel-arcgis-workflow-manager"
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
  description = "ArcGIS Workflow Manager version"
  type        = string
  default     = "11.5"
}

variable "java_version" {
  description = "Java version"
  type        = string
  default     = "17.0.13+11"
}

variable "tomcat_version" {
  description = "Tomcat version"
  type        = string
  default     = "9.0.106"
}

variable "deployment_bucket" {
  description = "S3 bucket containing software installers and licenses"
  type        = string
}

variable "workflow_installer_key_name" {
  description = "S3 key for ArcGIS Workflow Manager installer"
  type        = string
}

variable "webadaptor_installer_key_name" {
  description = "S3 key for ArcGIS Web Adaptor installer"
  type        = string
}

variable "java_openjdk_17_key_name" {
  description = "S3 key for Java OpenJDK 17 installer"
  type        = string
}

variable "tomcat_key_name" {
  description = "S3 key for Tomcat installer"
  type        = string
}

# Installation Path Configuration
variable "installer_directory_linux" {
  description = "Installer directory for ArcGIS WFM on Linux"
  type        = string
  default     = "/opt/software/esri"
}

variable "install_directory_linux" {
  description = "Installation directory for ArcGIS WFM on Linux"
  type        = string
  default     = "/opt/arcgis"
}

variable "data_directory_linux" {
  description = "Data directory for ArcGIS WFM on Linux"
  type        = string
  default     = "/opt/arcgis/data"
}

variable "supported_os_versions_linux" {
  description = "Supported Linux OS versions for the component"
  type        = list(string)
  default     = ["Red Hat Enterprise Linux 9", "Red Hat Enterprise Linux"]
}

# Build Configuration

variable "cidr_ingress_rules" {
  description = "Ingress rule for the CIDR network range"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = []
}

variable "cidr_egress_rules" {
  description = "Egress rule for the CIDR network range"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = []
}

variable "build_version" {
  description = "Build Version"
  type        = string
}

variable "recipe_version" {
  description = "Image Builder Recipe Version."
  type        = string
}

variable "ec2_imagebuilder_instance_type" {
  description = "EC2 instance type for building AMI"
  type        = list(string)
  default     = ["m5.large"]
}

variable "enable_enhanced_metadata" {
  description = "Enable enhanced image metadata collection"
  type        = bool
  default     = true
}

variable "block_device_throughput" {
  description = "Throughput in MiB/s for gp3 volumes only."
  type        = number
  default     = 200
}

variable "recipe_volume_size" {
  description = "Size of the volume for image recipe"
  type        = number
  default     = 50
}

variable "ami_name" {
  description = "Name of AMI"
  type        = string
}

variable "build_schedule" {
  description = "Cron expression for scheduled builds (optional)"
  type        = string
  default     = ""
}

# Testing Configuration
variable "enable_instance_tests" {
  description = "Enable instance testing before AMI creation"
  type        = bool
  default     = true
}

variable "test_timeout_minutes" {
  description = "Test timeout in minutes"
  type        = number
  default     = 60
}

# Image Builder S3 Bucket Configuration 
variable "force_destroy_s3_bucket" {
  description = "Whether to destroy the S3 bucket while destroying other resources"
  type        = bool
  default     = true
}

variable "log_policy" {
  description = "Policy for S3 bucket"
  type        = string
}

variable "bucket_name" {
  description = "Imagebuilder logs S3 bucket name"
  type        = string
}

# Distribution Configuration  
variable "distribution_regions" {
  description = "AWS regions to distribute AMI to"
  type        = list(string)
  default     = []
}
variable "share_with_accounts" {
  description = "List of AWS account IDs to share the AMI with"
  type        = list(string)
  default     = []
}
