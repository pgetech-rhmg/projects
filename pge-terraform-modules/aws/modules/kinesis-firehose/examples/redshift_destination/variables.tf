variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#Variables for kms
variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

#Variables for tags
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
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

#variables for kinesis firehose
variable "name" {
  description = "A common name for resources."
  type        = string
}

#variable for firehose
variable "kinesis_stream_arn" {
  description = "The kinesis stream used as the source of the firehose delivery stream."
  type        = string
}

variable "kinesis_stream_role_arn" {
  description = "The ARN of the role that provides access to the source Kinesis stream."
  type        = string
}
#s3 configuration
variable "prefix" {
  description = "The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket"
  type        = string
}

variable "s3_buffer_size" {
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher."
  type        = number
}

variable "s3_buffer_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300."
  type        = number
}

variable "compression_format" {
  description = "The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP_SNAPPY."
  type        = string
}

variable "error_output_prefix" {
  description = "Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects."
  type        = string
}

variable "s3_log_stream_name" {
  description = "The CloudWatch log stream name for logging. This value is required if enabled is true."
  type        = string
}

#redshift configuration
variable "s3_backup_mode" {
  description = "The Amazon S3 backup mode. Valid values are Disabled and Enabled. Default value is Disabled."
  type        = string
}

variable "retry_duration" {
  description = "The length of time during which Firehose retries delivery after a failure, starting from the initial request and including the first attempt. The default value is 3600 seconds (60 minutes). Firehose does not retry if the value of DurationInSeconds is 0 (zero) or if the first delivery attempt takes longer than the current value."
  type        = number
}

variable "copy_options" {
  description = "Copy options for copying the data from the s3 intermediate bucket into redshift, for example to change the default delimiter. For valid values, see the AWS documentation"
  type        = string
}

variable "data_table_columns" {
  description = "The data table columns that will be targeted by the copy command."
  type        = string
}

variable "redshift_log_stream_name" {
  description = "The CloudWatch log stream name for logging. This value is required if enabled is true."
  type        = string
}

#s3_backup_configuration
variable "s3_backup_prefix" {
  description = "The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket"
  type        = string
}

variable "s3_backup_buffer_size" {
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher."
  type        = number
}

variable "s3_backup_buffer_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300."
  type        = number
}

variable "s3_backup_compression_format" {
  description = "The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP_SNAPPY."
  type        = string
}

variable "s3_backup_error_output_prefix" {
  description = "Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects."
  type        = string
}

variable "s3_backup_log_stream_name" {
  description = "The CloudWatch log stream name for logging. This value is required if enabled is true."
  type        = string
}

variable "processing_configuration_enabled" {
  description = "Enables or disables data processing."
  type        = bool
}

variable "processing_configuration_processors" {
  description = "Array of data processors."
  type        = list(any)
}

#variables for iam role
variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
  default     = []
}

variable "path" {
  description = "The path of the policy in IAM"
  type        = string
}

#variables for ssm parameter Store
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


#variables for ssm parameter Store-Cluster
variable "parameter_vpc_id_name" {
  description = "Id of vpc stored in aws_ssm_parameter"
  type        = string
}

# Variables for Cluster
variable "node_type" {
  description = "The node type to be provisioned for the cluster."
  type        = string
}

variable "cluster_type" {
  description = "The cluster type to use. Either single-node or multi-node"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot of the cluster is created before Amazon Redshift deletes the cluster."
  type        = bool
}

variable "database_name" {
  description = "The name of the first database to be created when the cluster is created. If you do not provide a name, Amazon Redshift will create a default database called dev."
  type        = string
}

variable "s3_key_prefix" {
  description = "The prefix applied to the log file names."
  type        = string
}

#Variable for Time Sleep
variable "create_duration" {
  description = "Time duration to delay resource creation. For example, 30s for 30 seconds or 5m for 5 minutes. Updating this value by itself will not trigger a delay."
  type        = string
}