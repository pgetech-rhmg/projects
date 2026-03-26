# – Agent Core Gateway –

variable "create_gateway" {
  description = "Whether or not to create an agent core gateway."
  type        = bool
  default     = false
}

variable "gateway_name" {
  description = "The name of the agent core gateway."
  type        = string
  default     = "TerraformBedrockAgentCoreGateway"
}

variable "gateway_description" {
  description = "Description of the agent core gateway."
  type        = string
  default     = null
}

variable "gateway_role_arn" {
  description = "Optional external IAM role ARN for the Bedrock agent core gateway. If empty, the module will create one internally."
  type        = string
  default     = null
}

variable "gateway_authorizer_type" {
  description = "The authorizer type for the gateway. Valid values: AWS_IAM, CUSTOM_JWT."
  type        = string
  default     = "CUSTOM_JWT"

  validation {
    condition     = contains(["AWS_IAM", "CUSTOM_JWT"], var.gateway_authorizer_type)
    error_message = "The gateway_authorizer_type must be either AWS_IAM or CUSTOM_JWT."
  }
}

variable "gateway_protocol_type" {
  description = "The protocol type for the gateway. Valid value: MCP."
  type        = string
  default     = "MCP"

  validation {
    condition     = var.gateway_protocol_type == "MCP"
    error_message = "The gateway_protocol_type must be MCP."
  }
}

variable "gateway_exception_level" {
  description = "Exception level for the gateway. Valid values: PARTIAL, FULL."
  type        = string
  default     = null

  validation {
    condition     = var.gateway_exception_level == null || try(contains(["PARTIAL", "FULL"], var.gateway_exception_level), true)
    error_message = "The gateway_exception_level must be either PARTIAL or FULL."
  }
}

variable "gateway_kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt the gateway."
  type        = string
  default     = null
}

variable "gateway_authorizer_configuration" {
  description = "Authorizer configuration for the agent core gateway."
  type = object({
    custom_jwt_authorizer = object({
      allowed_audience = optional(list(string))
      allowed_clients  = optional(list(string))
      discovery_url    = string
    })
  })
  default = null
}

variable "gateway_protocol_configuration" {
  description = "Protocol configuration for the agent core gateway."
  type = object({
    mcp = object({
      instructions       = optional(string)
      search_type        = optional(string)
      supported_versions = optional(list(string))
    })
  })
  default = null
}

variable "gateway_tags" {
  description = "A map of tag keys and values for the agent core gateway."
  type        = map(string)
  default     = null
}

variable "gateway_allow_create_permissions" {
  description = "Whether to allow create permissions for the gateway."
  type        = bool
  default     = true
}

variable "gateway_allow_update_delete_permissions" {
  description = "Whether to allow update and delete permissions for the gateway."
  type        = bool
  default     = false
}

# - IAM -
variable "permissions_boundary_arn" {
  description = "The ARN of the IAM permission boundary for the role."
  type        = string
  default     = null
}

# - Lambda Function Access -
variable "gateway_lambda_function_arns" {
  description = "List of Lambda function ARNs that the gateway service role should be able to invoke. Required when using Lambda targets."
  type        = list(string)
  default     = []
}

variable "gateway_cross_account_lambda_permissions" {
  description = "Configuration for cross-account Lambda function access. Required only if Lambda functions are in different AWS accounts."
  type = list(object({
    lambda_function_arn      = string
    gateway_service_role_arn = string
  }))
  default = []
}

# - OAuth Outbound Authorization -
variable "enable_oauth_outbound_auth" {
  description = "Whether to enable outbound authorization with an OAuth client for the gateway."
  type        = bool
  default     = false
}

variable "oauth_credential_provider_arn" {
  description = "ARN of the OAuth credential provider created with CreateOauth2CredentialProvider. Required when enable_oauth_outbound_auth is true."
  type        = string
  default     = null
}

variable "oauth_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing the OAuth client credentials. Required when enable_oauth_outbound_auth is true."
  type        = string
  default     = null
}

# - API Key Outbound Authorization -
variable "enable_apikey_outbound_auth" {
  description = "Whether to enable outbound authorization with an API key for the gateway."
  type        = bool
  default     = false
}

variable "apikey_credential_provider_arn" {
  description = "ARN of the API key credential provider created with CreateApiKeyCredentialProvider. Required when enable_apikey_outbound_auth is true."
  type        = string
  default     = null
}

variable "apikey_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing the API key. Required when enable_apikey_outbound_auth is true."
  type        = string
  default     = null
}

# – Agent Core Gateway Target –

variable "create_gateway_target" {
  description = "Whether or not to create a Bedrock agent core gateway target."
  type        = bool
  default     = false
}

variable "gateway_target_name" {
  description = "The name of the gateway target."
  type        = string
  default     = "TerraformBedrockAgentCoreGatewayTarget"
}

variable "gateway_target_gateway_id" {
  description = "Identifier of the gateway that this target belongs to. If not provided, it will use the ID of the gateway created by this module."
  type        = string
  default     = null
}

variable "gateway_target_description" {
  description = "Description of the gateway target."
  type        = string
  default     = null
}

variable "gateway_target_credential_provider_type" {
  description = "Type of credential provider to use for the gateway target. Valid values: GATEWAY_IAM_ROLE, API_KEY, OAUTH."
  type        = string
  default     = "GATEWAY_IAM_ROLE"

  validation {
    condition     = var.gateway_target_credential_provider_type == null || contains(["GATEWAY_IAM_ROLE", "API_KEY", "OAUTH"], var.gateway_target_credential_provider_type)
    error_message = "The gateway_target_credential_provider_type must be one of GATEWAY_IAM_ROLE, API_KEY, OAUTH, or null."
  }
}

variable "gateway_target_api_key_config" {
  description = "Configuration for API key authentication for the gateway target."
  type = object({
    provider_arn              = string
    credential_location       = optional(string)
    credential_parameter_name = optional(string)
    credential_prefix         = optional(string)
  })
  default = null
}

variable "gateway_target_oauth_config" {
  description = "Configuration for OAuth authentication for the gateway target."
  type = object({
    provider_arn      = string
    scopes            = optional(list(string))
    custom_parameters = optional(map(string))
  })
  default = null
}

variable "gateway_target_type" {
  description = "Type of target to create. Valid values: LAMBDA, MCP_SERVER."
  type        = string
  default     = "LAMBDA"

  validation {
    condition     = var.gateway_target_type == null || contains(["LAMBDA", "MCP_SERVER"], var.gateway_target_type)
    error_message = "The gateway_target_type must be one of LAMBDA, MCP_SERVER, or null."
  }
}

variable "gateway_target_lambda_config" {
  description = "Configuration for Lambda function target."
  type = object({
    lambda_arn       = string
    tool_schema_type = string # INLINE or S3
    inline_schema = optional(object({
      name        = string
      description = string
      input_schema = object({
        type        = string
        description = optional(string)
        properties = optional(list(object({
          name        = string
          type        = string
          description = optional(string)
          required    = optional(bool, false)
          nested_properties = optional(list(object({
            name        = string
            type        = string
            description = optional(string)
            required    = optional(bool)
          })))
          items = optional(object({
            type        = string
            description = optional(string)
          }))
        })))
        items = optional(object({
          type        = string
          description = optional(string)
        }))
      })
      output_schema = optional(object({
        type        = string
        description = optional(string)
        properties = optional(list(object({
          name        = string
          type        = string
          description = optional(string)
          required    = optional(bool)
        })))
        items = optional(object({
          type        = string
          description = optional(string)
        }))
      }))
    }))
    s3_schema = optional(object({
      uri                     = string
      bucket_owner_account_id = optional(string)
    }))
  })
  default = null
}

variable "gateway_target_mcp_server_config" {
  description = "Configuration for MCP server target."
  type = object({
    endpoint = string
  })
  default = null
}