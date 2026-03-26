variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#variables for Tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

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
  description = "Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

#Variables for graphql_api
variable "authentication_type" {
  description = " Authentication type. Valid values: API_KEY, AWS_IAM, AMAZON_COGNITO_USER_POOLS, OPENID_CONNECT, AWS_LAMBDA."
  type        = string
}

variable "name" {
  description = "User-supplied name for the GraphqlApi."
  type        = string
}

variable "xray_enabled" {
  description = "Whether tracing with X-ray is enabled. Defaults to false."
  type        = bool
}

variable "visibility" {
  description = "Sets the value of the GraphQL API to public (GLOBAL) or private (PRIVATE). Defaults to GLOBAL if not set. Cannot be changed once set."
  type        = string
  default     = null
}

variable "additional_authentication_provider_authentication_type" {
  description = "One or more additional authentication providers for the GraphqlApi."
  type        = string
}

variable "issuer" {
  description = "Issuer for the OpenID Connect configuration. The issuer returned by discovery MUST exactly match the value of iss in the ID Token."
  type        = string
}

variable "client_id" {
  description = "Client identifier of the Relying party at the OpenID identity provider. This identifier is typically obtained when the Relying party is registered with the OpenID identity provider. You can specify a regular expression so the AWS AppSync can validate against multiple client identifiers at a time."
  type        = string
}

variable "web_acl_arn" {
  description = "The Amazon Resource Name (ARN) of the Web ACL that you want to associate with the resource."
  type        = string
}

#Variables for IAM
variable "domain_role_service" {
  description = "Aws service of the IAM role"
  type        = list(string)
}

#variables for domain_name
variable "domain_name" {
  description = "Name of the  Domain name."
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the certificate. This can be an Certificate Manager (ACM) certificate or an Identity and Access Management (IAM) server certificate. The certifiacte must reside in us-east-1."
  type        = string
}

#Variables for datasource
variable "type" {
  description = "Type of the Data Source. Valid values: AWS_LAMBDA, AMAZON_DYNAMODB, AMAZON_ELASTICSEARCH, HTTP, NONE, RELATIONAL_DATABASE."
  type        = string
}

#variables for function
variable "request_mapping_template" {
  description = "Function request mapping template. Functions support only the 2018-05-29 version of the request mapping template."
  type        = string
}

variable "response_mapping_template" {
  description = "Function response mapping template."
  type        = string
}

variable "max_batch_size" {
  description = "Maximum batching size for a resolver. Valid values are between 0 and 2000."
  type        = number
}

#Variables for Lambda

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
}

variable "description" {
  description = "Description of what your Lambda Function does"
  type        = string
}

variable "runtime" {
  description = " Identifier of the function's runtime"
  type        = string
}

variable "content" {
  description = "Add only this content to the archive with source_content_filename as the filename."
  type        = string
}

variable "filename" {
  description = "Set this as the filename when using source_content."
  type        = string
}

#Supporting Resource
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

variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

#variables for resolver
variable "resolver_type" {
  description = "Type name from the schema defined in the GraphQL API."
  type        = string
}

variable "field" {
  description = "Field name from the schema defined in the GraphQL API."
  type        = string
}

variable "request_template" {
  description = "Request mapping template for UNIT resolver or 'before mapping template' for PIPELINE resolver. Required for non-Lambda resolvers."
  type        = string
}

variable "response_template" {
  description = "Response mapping template for UNIT resolver or 'after mapping template' for PIPELINE resolver. Required for non-Lambda resolvers."
  type        = string
}

variable "kind" {
  description = "Resolver type. Valid values are UNIT and PIPELINE."
  type        = string
}