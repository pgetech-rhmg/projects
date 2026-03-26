# Variables for assume_role used in terraform.tf

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

# Variables for tags

variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

#support resource
variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id1 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "enter the value of subnet id2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "enter the value of subnet id3 stored in ssm parameter"
  type        = string
}

#Variables for IAM
variable "role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

# Variables for image_builder - COMMENTED OUT (image builder module is commented out)
# variable "image_name_imagebuilder" {
#   description = "Name of the image used to create the image builder."
#   type        = string
# }
# 
# variable "instance_type_imagebuilder" {
#   description = "The instance type to use when launching the image builder."
#   type        = string
# }
# 
# variable "appstream_agent_version" {
#   description = "The version of the AppStream 2.0 agent to use for this image builder."
#   type        = string
#   default     = "LATEST"
# }
# 
# variable "endpoint_type" {
#   description = "Type of interface endpoint"
#   type        = string
# }

# Variables used by multiple modules
variable "name" {
  description = "Unique name for the appstream resources."
  type        = string
}

variable "description" {
  description = "Description to display."
  type        = string
}

variable "display_name" {
  description = "Human-readable friendly name for the AppStream resources."
  type        = string
}

# ✅ DOMAIN JOIN INFO FOR IMAGE BUILDER - FULLY SUPPORTED
# Configuration for joining the image builder to Microsoft Active Directory
# Use this when you want the image builder itself to be domain-joined during creation
variable "domain_join_info" {
  description = "Configuration block for the name of the directory and organizational unit (OU) to use to join the image builder to a Microsoft Active Directory domain."
  type = object({
    directory_name                         = string
    organizational_unit_distinguished_name = optional(string)
  })
  default = null
}

#VPC endpoint variables - COMMENTED OUT (using internet access instead of VPC endpoints)
# variable "vpc_endpoint_type" {
#   description = "The VPC endpoint type"
#   type        = string
# }
# 
# variable "service_name" {
#   description = "he service name. For AWS services the service name is usually in the form com.amazonaws.<region>.<service>"
#   type        = string
# }
# 
# variable "private_dns_enabled" {
#   description = "Whether or not to associate a private hosted zone with the specified VPC. Applicable for endpoints of type Interface."
#   type        = bool
# }

#Variables for fleet
variable "instance_type" {
  description = "Instance type to use when launching fleet instances."
  type        = string
}

variable "fleet_type" {
  description = "Fleet type. Valid values are: ON_DEMAND, ALWAYS_ON,ELASTIC"
  type        = string
}

variable "desired_instances" {
  description = "Desired number of streaming instances."
  type        = number
}

variable "image_name" {
  description = "Name of the image used to create the fleet."
  type        = string
}

# ❌ COMMENTED OUT FOR DOMAIN-JOINED DEPLOYMENTS
# Variables for user - NOT REQUIRED for domain-joined AppStream
# Domain users authenticate through Active Directory, not AppStream user pools
# These variables are only needed when using USERPOOL authentication
# For domain authentication, users are managed in AD and don't need individual variables

# variable "authentication_type" {
#   description = "Authentication type for the user. You must specify USERPOOL."
#   type        = string
# }

# variable "user_name" {
#   description = "Email address of the user."
#   type        = string
# }

# variable "first_name" {
#   description = "First name, or given name, of the user."
#   type        = string
# }

# variable "last_name" {
#   description = "Last name, or surname, of the user."
#   type        = string
# }

# variable "enabled_user" {
#   description = "Specifies whether the user in the user pool is enabled."
#   type        = bool
# }

# Variables for stack - COMMENTED OUT (storage connector not used in domain-joined environment)
# variable "domains" {
#   description = "The names of the domains for the account."
#   type        = list(string)
# }
# 
# variable "resource_identifier" {
#   description = "The ARN of the storage connector."
#   type        = string
# }
# 
# variable "enabled" {
#   description = "Enables or disables persistent application settings for users during their streaming sessions."
#   type        = bool
# }
# 
# variable "settings_group" {
#   description = "The path prefix for the S3 bucket where users' persistent application settings are stored. You can allow the same persistent application settings to be used across multiple stacks by specifying the same settings group for each stack."
#   type        = string
# }

# ✅ REQUIRED FOR DOMAIN-JOINED DEPLOYMENTS
# Variables for directory config - ESSENTIAL for domain authentication
# ❌ COMMENTED OUT FOR DOMAIN-JOINED IMAGE BUILDER DEPLOYMENTS
# These variables configure Active Directory integration for runtime domain joining
# NOT REQUIRED when using pre-domain-joined image builders
# Domain authentication is already configured at the image level
# Only uncomment if you need directory_config module for runtime domain joining
# variable "directory_name" {
#   description = "Fully qualified name of the directory."
#   type        = string
# }
# 
# variable "organizational_unit_names" {
#   description = "Distinguished names of the organizational units for computer accounts."
#   type        = list(string)
# }
# 
# variable "ssm_parameter_directory_username" {
#   description = "User name of the account. This account must have the following privileges: create computer objects, join computers to the domain, and change/reset the password on descendant computer objects for the organizational units specified."
#   type        = string
# }
# 
# variable "ssm_parameter_directory_password" {
#   description = "Password for the account."
#   type        = string
# }

