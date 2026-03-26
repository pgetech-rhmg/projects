#As per SAF rule No:08 'API_KEY' is not allowed
#As confirmed by PG&E only 'AWS_IAM' & 'OPENID_CONNECT' types are allowed 
variable "authentication_type" {
  description = " Authentication type. Valid values: AWS_IAM, AMAZON_COGNITO_USER_POOLS, OPENID_CONNECT, AWS_LAMBDA."
  type        = string
  validation {
    condition     = contains(["AWS_IAM", "OPENID_CONNECT"], var.authentication_type)
    error_message = "Error! values for 'authentication_type' should be 'AWS_IAM, OPENID_CONNECT' only."
  }
}

variable "name" {
  description = "User-supplied name for the GraphqlApi."
  type        = string
}

variable "schema" {
  description = "Schema definition, in GraphQL schema language format. Terraform cannot perform drift detection of this configuration."
  type        = string
  default     = null
}

variable "xray_enabled" {
  description = "Whether tracing with X-ray is enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "visibility" {
  description = "Sets the value of the GraphQL API to public (GLOBAL) or private (PRIVATE). Defaults to GLOBAL if not set. Cannot be changed once set."
  type        = string
  default     = null
}

variable "cloudwatch_logs_role_arn" {
  description = "Amazon Resource Name of the service role that AWS AppSync will assume to publish to Amazon CloudWatch logs in your account."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.cloudwatch_logs_role_arn))
    ])
    error_message = "Cloudwatch_logs_role_arn is required and the allowed format is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

#As per SAF rule No:27
variable "openid_connect_config" {
  description = <<-DOC
    issuer :
    Issuer for the OpenID Connect configuration. The issuer returned by discovery MUST exactly match the value of issuer in the ID Token.
   auth_ttl : 
    Number of milliseconds a token is valid after being authenticated.
    client_id :
      Client identifier of the Relying party at the OpenID identity provider. This identifier is typically obtained when the Relying party is registered with the OpenID identity provider. You can specify a regular expression so the AWS AppSync can validate against multiple client identifiers at a time.
    iat_ttl :
      Number of milliseconds a token is valid after being issued to a user.
  DOC

  type = object({
    issuer    = string
    auth_ttl  = optional(number)
    client_id = optional(string)
    iat_ttl   = optional(number)

  })
  default = {
    auth_ttl  = null
    client_id = null
    iat_ttl   = null
    issuer    = null
  }
  validation {
    condition     = var.openid_connect_config.issuer != null ? contains(["https://itiampingdev.cloud.pge.com", "https://itiamping.cloud.pge.com", "https://idp.cloud.pge.com", "https://idpd.cloud.pge.com", "https://itiampingqa.cloud.pge.com", "https://idpq.cloud.pge.com"], var.openid_connect_config.issuer) : true
    error_message = "Valid values for 'issuer' are https://itiampingdev.cloud.pge.com,https://itiamping.cloud.pge.com,https://idp.cloud.pge.com,https://idpd.cloud.pge.com,https://itiampingqa.cloud.pge.com,https://idpq.cloud.pge.com."
  }
}

variable "user_pool_config" {
  description = <<-DOC
    default_action :
    Action that you want your GraphQL API to take when a request that uses Amazon Cognito User Pool authentication doesn't match the Amazon Cognito User Pool configuration.
   user_pool_id : 
    User pool ID.
   app_id_client_regex :
      Regular expression for validating the incoming Amazon Cognito User Pool app client ID.
   aws_region :
      AWS region in which the user pool was created.
  DOC

  type = object({
    default_action      = string
    user_pool_id        = string
    app_id_client_regex = optional(string)
    aws_region          = optional(string)
  })
  default = {
    app_id_client_regex = null
    aws_region          = null
    default_action      = null
    user_pool_id        = null
  }
  validation {
    condition     = var.user_pool_config.default_action != null ? contains(["ALLOW", "DENY"], var.user_pool_config.default_action) : true
    error_message = "Error! values for 'default_action' should be 'ALLOW, DENY'."
  }
}

variable "lambda_authorizer_config" {
  description = <<-DOC
    authorizer_uri :
    ARN of the Lambda function to be called for authorization. Note: This Lambda function must have a resource-based policy assigned to it, to allow lambda:InvokeFunction from service principal 'appsync.amazonaws.com'.
   authorizer_result_ttl_in_seconds : 
    Number of seconds a response should be cached for. The default is 5 minutes (300 seconds). The Lambda function can override this by returning a ttlOverride key in its response. A value of 0 disables caching of responses. Minimum value of 0. Maximum value of 3600.
    identity_validation_expression:
      Regular expression for validation of tokens before the Lambda function is called.
  DOC

  type = object({
    authorizer_uri                   = string
    authorizer_result_ttl_in_seconds = optional(number)
    identity_validation_expression   = optional(string)
  })
  default = {
    authorizer_result_ttl_in_seconds = null
    identity_validation_expression   = null
    authorizer_uri                   = ""
  }
}

variable "additional_authentication_provider" {
  description = "One or more additional authentication providers for the GraphqlApi."
  type        = list(any)
  default     = []
  validation {
    condition     = alltrue([for va in var.additional_authentication_provider : contains(["AWS_IAM", "OPENID_CONNECT"], lookup(va, "authentication_type"))])
    error_message = "Error! values for 'authentication_type' should be 'AWS_IAM, OPENID_CONNECT' only."
  }
  validation {
    condition     = alltrue(flatten([for val in var.additional_authentication_provider : [for ki, vi in val : [for kj, vj in vi : contains(["https://itiampingdev.cloud.pge.com", "https://itiamping.cloud.pge.com", "https://idp.cloud.pge.com", "https://idpd.cloud.pge.com", "https://itiampingqa.cloud.pge.com", "https://idpq.cloud.pge.com"], vj) if kj == "issuer"] if ki == "openid_connect_config"]]))
    error_message = "Valid values for 'issuer' are https://itiampingdev.cloud.pge.com,https://itiamping.cloud.pge.com,https://idp.cloud.pge.com,https://idpd.cloud.pge.com,https://itiampingqa.cloud.pge.com,https://idpq.cloud.pge.com."
  }
}

variable "web_acl_arn" {
  description = "The Amazon Resource Name (ARN) of the Web ACL that you want to associate with the resource."
  type        = string
}

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}