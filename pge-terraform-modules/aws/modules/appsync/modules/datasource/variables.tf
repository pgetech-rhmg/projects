variable "api_id" {
  description = "API ID for the GraphQL API for the data source."
  type        = string
}

variable "name" {
  description = "User-supplied name for the data source."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_]*$", var.name))
    error_message = "Error! The acceptable characters are lowercase letters, numbers, and the underscore character."
  }
}

variable "description" {
  description = "Description of the data source."
  type        = string
  default     = null
}

variable "service_role_arn" {
  description = "IAM service role ARN for the data source."
  type        = string
}

variable "config" {
  description = <<-DOC
    type:
      Type of the Data Source. Valid values: AWS_LAMBDA, AMAZON_DYNAMODB, AMAZON_ELASTICSEARCH, HTTP, NONE, RELATIONAL_DATABASE.
    dynamodb_config:
      table_name:
       Name of the DynamoDB table.
      region:
       AWS region of the DynamoDB table. Defaults to current region.
      use_caller_credentials:
       Set to true to use Amazon Cognito credentials with this data source.
      versioned:
       Set to TRUE to use Conflict Detection and Resolution with this data source.
    elasticsearch_config:
      endpoint:
       HTTP endpoint of the Elasticsearch domain.
      region:
       AWS region of Elasticsearch domain. Defaults to current region.
    http_config:
      endpoint:
       HTTP URL.
      authentication_type:
       Authorization type that the HTTP endpoint requires. Default values is AWS_IAM.
      signing_region:
       Signing Amazon Web Services Region for IAM authorization.
      signing_service_name:
       Signing service name for IAM authorization.
    lambda_config:
      function_arn:
       ARN for the Lambda function.
    relational_database_config:
      db_cluster_identifier:
       Amazon RDS cluster identifier.
      aws_secret_store_arn:
       AWS secret store ARN for database credentials.  
      source_type:
       Source type for the relational database. Valid values: RDS_HTTP_ENDPOINT.
      region:
       AWS Region for RDS HTTP endpoint. Defaults to current region.
      schema:
       Logical schema name.
    DOC

  type = object({
    type = string
    dynamodb_config = optional(object({
      table_name             = string
      region                 = string
      use_caller_credentials = optional(bool)
      versioned              = optional(bool)
    }))
    elasticsearch_config = optional(object({
      endpoint = string
      region   = string
    }))
    http_config = optional(object({
      endpoint             = string
      authentication_type  = optional(string)
      signing_region       = optional(string)
      signing_service_name = optional(string)
    }))
    lambda_config = optional(object({
      function_arn = string
    }))
    relational_database_config = optional(object({
      source_type = optional(string, "RDS_HTTP_ENDPOINT")
    }))
    http_endpoint_config = optional(object({
      db_cluster_identifier = string
      aws_secret_store_arn  = string
      database_name         = optional(string)
      region                = optional(string)
      schema                = optional(string)
    }))
  })

  validation {
    condition     = contains(["AWS_LAMBDA", "AMAZON_DYNAMODB", "AMAZON_ELASTICSEARCH", "HTTP", "NONE", "RELATIONAL_DATABASE"], var.config.type)
    error_message = "Error! Valid values for type are AWS_LAMBDA, AMAZON_DYNAMODB, AMAZON_ELASTICSEARCH, HTTP, NONE, RELATIONAL_DATABASE."
  }

  validation {
    condition     = var.config.type == "AMAZON_DYNAMODB" && var.config.dynamodb_config == null ? false : true
    error_message = "Error! 'dynamodb_config' is requred if type is 'AMAZON_DYNAMODB'."
  }

  validation {
    condition     = var.config.type == "AWS_LAMBDA" && var.config.lambda_config == null ? false : true
    error_message = "Error! 'lambda_config' is requred if type is 'AWS_LAMBDA'."
  }

  validation {
    condition     = var.config.type == "AMAZON_ELASTICSEARCH" && var.config.elasticsearch_config == null ? false : true
    error_message = "Error! 'elasticsearch_config' is requred if type is 'AMAZON_ELASTICSEARCH'."
  }

  validation {
    condition     = var.config.type == "HTTP" && var.config.http_config == null ? false : true
    error_message = "Error! 'http_config' is requred if type is 'HTTP'."
  }

  validation {
    condition     = var.config.type == "RELATIONAL_DATABASE" && var.config.relational_database_config == null ? false : true
    error_message = "Error! 'relational_database_config' is requred if type is 'RELATIONAL_DATABASE'."
  }

  validation {
    condition     = var.config.relational_database_config != null ? alltrue([for ki, vi in var.config.relational_database_config : contains(["RDS_HTTP_ENDPOINT"], vi) if ki == "source_type"]) : true
    error_message = "Error! Valid value for relational_database_config source_type are RDS_HTTP_ENDPOINT."
  }

}
