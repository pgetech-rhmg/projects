# Variable for tags

variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for dms source endpoint

# Variable for 'Database endpoint identifiers' must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens.
variable "source_endpoint_id" {
  description = "Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
  type        = string
}

# Variable for 'source_endpoint_engine_name'.Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). 
variable "source_endpoint_engine_name" {
  description = "Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift)."
  type        = string
}

variable "source_endpoint_kms_key_arn" {
  description = "ARN for the KMS key that will be used to encrypt the connection parameters."
  type        = string
}

variable "source_endpoint_database_name" {
  description = "Name of the endpoint database."
  type        = string
  default     = null
}

variable "source_endpoint_extra_connection_attributes" {
  description = "Additional attributes associated with the connection."
  type        = string
  default     = null
}

variable "source_endpoint_password" {
  description = "Password to be used to login to the endpoint database."
  type        = string
}

variable "source_endpoint_port" {
  description = "Port used by the endpoint database."
  type        = string
}

variable "source_endpoint_server_name" {
  description = "Host name of the server."
  type        = string
}

variable "source_endpoint_service_access_role" {
  description = "ARN used by the service access IAM role for dynamodb endpoints."
  type        = string
  default     = null
}

variable "source_endpoint_ssl_mode" {
  description = "SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'."
  type        = string
  validation {
    condition = anytrue([
      var.source_endpoint_ssl_mode == "require",
      var.source_endpoint_ssl_mode == "verify-ca",
      var.source_endpoint_ssl_mode == "verify-full",
    ])
    error_message = "Error! As per SAF Rule, for each DMS endpoint where there is a port required, check to make sure the SSLMode is not 'None'."
  }
}

variable "source_endpoint_username" {
  description = "User name to be used to login to the endpoint database."
  type        = string
}

variable "source_certificate_arn" {
  description = "ARN of the source SSL certificate"
  type        = string
  default     = null # Set an initial value (null or empty string)

}

# Variables for dms target endpoint

# Variable for 'Database endpoint identifiers' must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens.
variable "target_endpoint_id" {
  description = "Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
  type        = string
}

# Variable for 'target_endpoint_engine_name'.Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). 
variable "target_endpoint_engine_name" {
  description = "Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift)."
  type        = string
}

variable "target_endpoint_kms_key_arn" {
  description = "ARN for the KMS key that will be used to encrypt the connection parameters."
  type        = string
}

variable "target_endpoint_database_name" {
  description = "Name of the endpoint database."
  type        = string
  default     = null
}

variable "target_endpoint_extra_connection_attributes" {
  description = "Additional attributes associated with the connection."
  type        = string
  default     = null
}

variable "target_endpoint_password" {
  description = "Password to be used to login to the endpoint database."
  type        = string
}

variable "target_endpoint_port" {
  description = "Port used by the endpoint database."
  type        = string
}

variable "target_endpoint_server_name" {
  description = "Host name of the server."
  type        = string
}

variable "target_endpoint_service_access_role" {
  description = "ARN used by the service access IAM role for dynamodb endpoints."
  type        = string
  default     = null
}

variable "target_endpoint_ssl_mode" {
  description = "SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAf, For each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'."
  type        = string
  validation {
    condition = anytrue([
      var.target_endpoint_ssl_mode == "require",
      var.target_endpoint_ssl_mode == "verify-ca",
      var.target_endpoint_ssl_mode == "verify-full",
    ])
    error_message = "Error! As per SAF Rule,For each DMS endpoint where there is a port required, check to make sure the SSLMode is not 'None'."
  }
}

variable "target_endpoint_username" {
  description = "User name to be used to login to the endpoint database."
  type        = string
}



variable "target_certificate_arn" {
  description = "ARN of the target SSL certificate"
  type        = string
  default     = null # Set an initial value (null or empty string)
}
