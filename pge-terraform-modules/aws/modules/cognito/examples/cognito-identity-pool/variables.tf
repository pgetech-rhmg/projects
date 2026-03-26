variable "identity_pool_name" {
  description = "The name of the identity pool"
  type        = string
}

variable "allow_unauthenticated_identities" {
  description = "Whether the identity pool supports unauthenticated logins or not"
  type        = bool
  default     = false
}


variable "openid_connect_provider_arns" {
  description = "A list of OpenID Connect provider ARNs"
  type        = list(string)
  default     = []
}

variable "saml_provider_arns" {
  description = "A list of SAML provider ARNs"
  type        = list(string)
  default     = []
}



variable "allow_classic_flow" {
  description = "Whether the identity pool allows the classic flow or not"
  type        = bool
  default     = false
}



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


#### IAM  Variables ####
variable "description" {
  description = "Description of the role"
  type        = string
  default     = "IAM Role created by pge_team = ccoe-tf-developers"
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = false
}

variable "path" {
  description = "The path to the role in IAM"
  type        = string
  default     = "/"
}
variable "name" {
  description = "The name prefix for these IAM resources"
  type        = string
}

variable "max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  type        = number
  default     = 3600
}

variable "permission_boundary" {
  description = "IAM policy ARN limiting the maximum access this role can have"
  type        = string
  default     = ""
}

variable "inline_policy" {
  description = "A list of strings.  Each string should contain a json string to use for this inline policy or pass as a file name in json"
  type        = list(string)
  default     = []
}
