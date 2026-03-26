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

# Variables for source endpoint

variable "source_endpoint_id" {
  description = "Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
  type        = string
}

variable "source_endpoint_engine_name" {
  description = "Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift)."
  type        = string
}

variable "source_endpoint_ssl_mode" {
  description = "SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'."
  type        = string
}

variable "source_endpoint_server_name" {
  description = "Name of the endpoint database."
  type        = string
}



variable "source_endpoint_port" {
  description = "Port used by the endpoint database."
  type        = string
}

variable "source_endpoint_database_name" {
  description = "Name of the endpoint database."
  type        = string
}

variable "source_certificate_arn" {
  description = "ARN of the source SSL certificate"
  type        = string
}



# Variables for target endpoint

variable "target_endpoint_id" {
  description = "Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
  type        = string
}

variable "target_endpoint_engine_name" {
  description = "Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift)."
  type        = string
}

variable "target_endpoint_ssl_mode" {
  description = "SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'."
  type        = string
}

variable "target_endpoint_server_name" {
  description = "Name of the endpoint database."
  type        = string
}

variable "target_endpoint_username" {
  description = "User name to be used to login to the endpoint database."
  type        = string
}

variable "target_endpoint_password" {
  description = "Password to be used to login to the endpoint database."
  type        = string
}

variable "target_endpoint_port" {
  description = "Port used by the endpoint database."
  type        = string
}

variable "target_endpoint_database_name" {
  description = "Name of the endpoint database."
  type        = string
}


variable "target_certificate_arn" {
  description = "ARN of the target SSL certificate"
  type        = string
}

# Variables for KMS

variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

# Support Resource

variable "ssm_parameter_dms_username" {
  description = "Enter the value of dms_username stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_dms_password" {
  description = "enter the value of dms_password stored in ssm parameter"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}