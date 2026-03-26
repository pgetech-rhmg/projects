#Variables for provider

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
#KMS role

variable "kms_role" {
  description = "AWS role to administer the KMS key."
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
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

# Variables for Glue Resources

variable "name" {
  description = "The name you assign to the Glue resources. It must be unique in your account."
  type        = string
}

# Variables for Glue Job

variable "glue_job_command" {
  description = "The command of the job. Includes 'name', 'script_location' and 'python_version'."
  type        = list(map(string))
}


# Variables for IAM

variable "role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

# Variables for Glue Connection

variable "glue_connection_type" {
  description = "The type of the connection. Supported are: JDBC, MONGODB, KAFKA, and NETWORK. Defaults to JBDC."
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the glue connection."
  type        = string
}

# Variables for Glue Dev Endpoint

variable "glue_dev_endpoint_arguments" {
  description = "A map of arguments used to configure the endpoint."
  type        = map(string)
}

variable "glue_dev_endpoint_extra_jars_s3_path" {
  description = "Path to one or more Java Jars in an S3 bucket that should be loaded in this endpoint."
  type        = string
}

variable "glue_dev_endpoint_extra_python_libs_s3_path" {
  description = "Path(s) to one or more Python libraries in an S3 bucket that should be loaded in this endpoint. Multiple values must be complete paths separated by a comma."
  type        = string
}

variable "glue_dev_endpoint_glue_version" {
  description = "Specifies the versions of Python and Apache Spark to use. Defaults to AWS Glue version 0.9."
  type        = string
}

variable "glue_dev_endpoint_number_of_workers" {
  description = "The number of workers of a defined worker type that are allocated to this endpoint. This field is available only when you choose worker type G.1X or G.2X."
  type        = number
}

variable "glue_dev_endpoint_number_of_nodes" {
  description = "The number of AWS Glue Data Processing Units (DPUs) to allocate to this endpoint."
  type        = number
}

variable "glue_dev_endpoint_worker_type" {
  description = "The type of predefined worker that is allocated to this endpoint. Accepts a value of Standard, G.1X, or G.2X."
  type        = string
}

variable "glue_dev_endpoint_public_key" {
  description = "The public key to be used by this endpoint for authentication."
  type        = string
}

variable "glue_dev_endpoint_public_keys" {
  description = "A list of public keys to be used by this endpoint for authentication."
  type        = list(string)
}

# Variables for SSM Parameters

variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id_1 stored in ssm parameter"
  type        = string
}

# Variables for Glue Trigger

variable "glue_trigger_type" {
  description = "The type of trigger.Valid values are CONDITIONAL, ON_DEMAND, and SCHEDULED."
  type        = string
}

variable "glue_trigger_predicate" {
  description = "A predicate to specify when the new trigger should fire.Required when trigger type is CONDITIONAL."
  type        = list(map(string))
}

# Variables for Security Group

variable "cidr_blocks" {
  description = "List of CIDR blocks."
  type        = list(string)
}

