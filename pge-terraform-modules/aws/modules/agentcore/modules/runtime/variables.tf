# – Agent Core Runtime –

variable "create_runtime" {
  description = "Whether or not to create an agent core runtime."
  type        = bool
  default     = false
}

variable "runtime_name" {
  description = "The name of the agent core runtime."
  type        = string
  default     = "TerraformBedrockAgentCoreRuntime"
}

variable "runtime_description" {
  description = "Description of the agent runtime."
  type        = string
  default     = null
}

variable "runtime_role_arn" {
  description = "Optional external IAM role ARN for the Bedrock agent core runtime. If empty, the module will create one internally."
  type        = string
  default     = null
}

variable "runtime_artifact_type" {
  description = "The type of artifact to use for the agent core runtime. Valid values: container, code."
  type        = string
  default     = "container"

  validation {
    condition     = contains(["container", "code"], var.runtime_artifact_type)
    error_message = "The runtime_artifact_type must be either container or code."
  }
}

variable "runtime_container_uri" {
  description = "The ECR URI of the container for the agent core runtime. Required when runtime_artifact_type is set to 'container'."
  type        = string
  default     = null
}

variable "runtime_code_s3_bucket" {
  description = "S3 bucket containing the code package for the agent core runtime. Required when runtime_artifact_type is set to 'code'."
  type        = string
  default     = null
}

variable "runtime_code_s3_prefix" {
  description = "S3 prefix (key) for the code package. Required when runtime_artifact_type is set to 'code'."
  type        = string
  default     = null
}

variable "runtime_code_s3_version_id" {
  description = "S3 version ID of the code package. Optional when runtime_artifact_type is set to 'code'."
  type        = string
  default     = null
}

variable "runtime_code_entry_point" {
  description = "Entry point for the code runtime. Required when runtime_artifact_type is set to 'code'."
  type        = list(string)
  default     = null
}

variable "runtime_code_runtime_type" {
  description = "Runtime type for the code. Required when runtime_artifact_type is set to 'code'. Valid values: PYTHON_3_10, PYTHON_3_11, PYTHON_3_12, PYTHON_3_13"
  type        = string
  default     = null

  validation {
    condition     = var.runtime_code_runtime_type == null ? true : contains(["PYTHON_3_10", "PYTHON_3_11", "PYTHON_3_12", "PYTHON_3_13"], var.runtime_code_runtime_type)
    error_message = "The runtime_code_runtime_type must be one of: PYTHON_3_10, PYTHON_3_11, PYTHON_3_12, PYTHON_3_13."
  }
}

variable "runtime_network_configuration" {
  description = "VPC network configuration for the agent core runtime."
  type = object({
    security_groups = optional(list(string))
    subnets         = optional(list(string))
  })
  default = null
}

variable "runtime_network_mode" {
  description = "Network mode for the agent core runtime. Valid value: VPC."
  type        = string
  default     = "VPC"

  validation {
    condition     = var.runtime_network_mode == "VPC"
    error_message = "The runtime_network_mode must be VPC."
  }
}

variable "runtime_environment_variables" {
  description = "Environment variables for the agent core runtime."
  type        = map(string)
  default     = null
}

variable "runtime_authorizer_configuration" {
  description = "Authorizer configuration for the agent core runtime."
  type = object({
    custom_jwt_authorizer = object({
      allowed_audience = optional(list(string))
      allowed_clients  = optional(list(string))
      discovery_url    = string
    })
  })
  default = null
}

variable "runtime_protocol_configuration" {
  description = "Protocol configuration for the agent core runtime."
  type        = string
  default     = null
}

variable "runtime_lifecycle_configuration" {
  description = "Lifecycle configuration for managing runtime sessions."
  type = object({
    idle_runtime_session_timeout = optional(number)
    max_lifetime                 = optional(number)
  })
  default = null
}

variable "runtime_request_header_configuration" {
  description = "Configuration for HTTP request headers."
  type = object({
    request_header_allowlist = optional(set(string))
  })
  default = null
}

variable "runtime_tags" {
  description = "A map of tag keys and values for the agent core runtime."
  type        = map(string)
  default     = null
}

# – Agent Core Runtime Endpoint –

variable "create_runtime_endpoint" {
  description = "Whether or not to create an agent core runtime endpoint."
  type        = bool
  default     = false
}

variable "runtime_endpoint_name" {
  description = "The name of the agent core runtime endpoint."
  type        = string
  default     = "TerraformBedrockAgentCoreRuntimeEndpoint"
}

variable "runtime_endpoint_description" {
  description = "Description of the agent core runtime endpoint."
  type        = string
  default     = null
}

variable "runtime_endpoint_agent_runtime_id" {
  description = "The ID of the agent core runtime associated with the endpoint. If not provided, it will use the ID of the agent runtime created by this module."
  type        = string
  default     = null
}

variable "runtime_endpoint_tags" {
  description = "A map of tag keys and values for the agent core runtime endpoint."
  type        = map(string)
  default     = null
}

variable "permissions_boundary_arn" {
  description = "The ARN of the permissions boundary policy to attach to the runtime IAM role."
  type        = string
  default     = null
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

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
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

variable "Order" {
  type        = number
  description = "Order as a tag to be associated with an AWS resource"
}
