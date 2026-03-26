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

variable "issuer2" {
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

variable "policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

#Variables for datasource
variable "type" {
  description = "Type of the Data Source. Valid values: AWS_LAMBDA, AMAZON_DYNAMODB, AMAZON_ELASTICSEARCH, HTTP, NONE, RELATIONAL_DATABASE."
  type        = string
}

variable "versioned" {
  description = "Set to TRUE to use Conflict Detection and Resolution with this data source."
  type        = bool
}

#Variables for dynamodb table
variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined as an attribute"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key. Must also be defined as an attribute"
  type        = string
  default     = null
}

variable "hash_range_key_attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(map(string))
}

variable "local_secondary_indexes" {
  description = "Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc."
  type        = list(any)
}

variable "stream_enabled" {
  description = "Indicates whether Streams are to be enabled (true) or disabled (false)."
  type        = bool
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values for stream view type should be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE and NEW_AND_OLD_IMAGES when the stream is enabled and value must be null when stream is disabled."
  type        = string
}

variable "ttl_enabled" {
  description = "Indicates whether ttl is enabled"
  type        = bool
}

variable "ttl_attribute_name" {
  description = "The name of the table attribute to store the TTL timestamp in"
  type        = string
}

# Variables for KMS
variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
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

#variables for function
variable "request_mapping_template" {
  description = "Function request mapping template. Functions support only the 2018-05-29 version of the request mapping template."
  type        = string
}

variable "response_mapping_template" {
  description = "Function response mapping template."
  type        = string
}

variable "conflict_detection" {
  description = "Conflict Detection strategy to use. Valid values are NONE and VERSION."
  type        = string
}

variable "conflict_handler" {
  description = "Conflict Resolution strategy to perform in the event of a conflict. Valid values are NONE, OPTIMISTIC_CONCURRENCY, AUTOMERGE, and LAMBDA."
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

variable "caching_keys" {
  description = "List of caching key."
  type        = list(string)
}

variable "ttl" {
  description = "TTL in seconds."
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