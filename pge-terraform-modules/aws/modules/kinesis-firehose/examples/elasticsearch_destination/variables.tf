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

variable "kms_role" {
  description = "KMS role to assume"
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

#common variable for name
variable "name" {
  description = "A common name for resources."
  type        = string
}

#variable for firehose
variable "kinesis_stream_arn" {
  description = "The kinesis stream used as the source of the firehose delivery stream."
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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

#elasticsearch configuration
variable "index_name" {
  description = "The Elasticsearch index name."
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint to use when communicating with the cluster. Conflicts with domain_arn."
  type        = string
}

variable "buffering_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds between 60 to 900, before delivering it to the destination. The default value is 300s."
  type        = number
}

variable "buffering_size" {
  description = "Buffer incoming data to the specified size, in MBs between 1 to 100, before delivering it to the destination. The default value is 5MB."
  type        = number
}

variable "index_rotation_period" {
  description = "index_rotation_periodThe Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data. Valid values are NoRotation, OneHour, OneDay, OneWeek, and OneMonth. The default value is OneDay."
  type        = string
}

variable "s3_backup_mode" {
  description = "Defines how documents should be delivered to Amazon S3. Valid values are FailedDocumentsOnly and AllDocuments. Default value is FailedDocumentsOnly."
  type        = string
}

variable "type_name" {
  description = "The Elasticsearch type name with maximum length of 100 characters."
  type        = string
}

variable "retry_duration" {
  description = "Total amount of seconds Firehose spends on retries. Valid values between 0 and 7200. Default is 300."
  type        = string
}

variable "elasticsearch_log_stream_name" {
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


#variables for elasticsearch resource
variable "domain_name" {
  description = "Name of the domain."
  type        = string
}

variable "instance_count" {
  description = "Number of instances in the cluster."
  type        = number
}

variable "zone_awareness_enabled" {
  description = "Whether zone awareness is enabled, set to true for multi-az deployment. To enable awareness with three Availability Zones, the availability_zone_count within the zone_awareness_config must be set to 3."
  type        = bool
}

variable "instance_type" {
  description = "Instance type of data nodes in the cluster."
  type        = string
}

variable "ebs_enabled" {
  description = "Whether EBS volumes are attached to data nodes in the domain."
  type        = bool
}

variable "volume_size" {
  description = "Size of EBS volumes attached to data nodes (in GiB)."
  type        = number
}