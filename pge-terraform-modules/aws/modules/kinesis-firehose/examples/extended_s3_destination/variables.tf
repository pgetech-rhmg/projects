variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "kms_role" {
  description = "KMS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
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

variable "server_side_encryption_key_arn" {
  description = "Amazon Resource Name (ARN) of the encryption key. Required when key_type is CUSTOMER_MANAGED_CMK."
  type        = string
}

variable "s3_backup_mode" {
  description = "The Amazon S3 backup mode. Valid values are Disabled and Enabled. Default value is Disabled."
  type        = string
}

variable "enable_server_side_encryption" {
  description = "Flag to enable server side encryption"
  type        = bool
}

variable "prefix" {
  description = "The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket"
  type        = string
}

variable "buffer_size" {
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher."
  type        = number
}

variable "buffer_interval" {
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

variable "log_stream_name" {
  description = "The CloudWatch log stream name for logging. This value is required if enabled is true."
  type        = string
}

variable "data_format_conversion_enabled" {
  description = "Defaults to true. Set it to false if you want to disable format conversion while preserving the configuration details."
  type        = bool
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

variable "deserializer" {
  description = "Provide value either 'hive_json_ser_de' or 'open_x_json_ser_de' to select respective block to execute."
  type        = string
}

variable "hive_json_ser_de_timestamp_formats" {
  description = "A list of how you want Kinesis Data Firehose to parse the date and time stamps that may be present in your input data JSON. To specify these format strings, follow the pattern syntax of JodaTime's DateTimeFormat format strings. For more information, see Class DateTimeFormat. You can also use the special value millis to parse time stamps in epoch milliseconds. If you don't specify a format, Kinesis Data Firehose uses java.sql.Timestamp::valueOf by default."
  type        = list(string)
}

variable "open_x_json_ser_de_case_insensitive" {
  description = "When set to true, which is the default, Kinesis Data Firehose converts JSON keys to lowercase before deserializing them."
  type        = bool
}

variable "open_x_json_ser_de_column_to_json_key_mappings" {
  description = "A map of column names to JSON keys that aren't identical to the column names. This is useful when the JSON contains keys that are Hive keywords. For example, timestamp is a Hive keyword. If you have a JSON key named timestamp, set this parameter to { ts = 'timestamp' } to map this key to a column named ts."
  type        = map(string)
}

variable "open_x_json_ser_de_convert_dots_in_json_keys_to_underscores" {
  description = "When set to true, specifies that the names of the keys include dots and that you want Kinesis Data Firehose to replace them with underscores. This is useful because Apache Hive does not allow dots in column names. For example, if the JSON contains a key whose name is 'a.b', you can define the column name to be 'a_b' when using this option. Defaults to false."
  type        = bool
}

variable "serializer" {
  description = "Provide value either 'orc_ser_de' or ;parquet_ser_de' to select respective block to execute."
  type        = string
}

variable "orc_ser_de_block_size_bytes" {
  description = "The Hadoop Distributed File System (HDFS) block size. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 256 MiB and the minimum is 64 MiB. Kinesis Data Firehose uses this value for padding calculations."
  type        = number
}

variable "orc_ser_de_bloom_filter_columns" {
  description = "A list of column names for which you want Kinesis Data Firehose to create bloom filters."
  type        = list(string)
}

variable "orc_ser_de_bloom_filter_false_positive_probability" {
  description = "The Bloom filter false positive probability (FPP). The lower the FPP, the bigger the Bloom filter. The default value is 0.05, the minimum is 0, and the maximum is 1."
  type        = number
}

variable "orc_ser_de_compression" {
  description = "The compression code to use over data blocks. The possible values are UNCOMPRESSED, SNAPPY, and GZIP, with the default being SNAPPY. Use SNAPPY for higher decompression speed. Use GZIP if the compression ratio is more important than speed."
  type        = string
}

variable "orc_ser_de_dictionary_key_threshold" {
  description = "A float that represents the fraction of the total number of non-null rows. To turn off dictionary encoding, set this fraction to a number that is less than the number of distinct keys in a dictionary. To always use dictionary encoding, set this threshold to 1."
  type        = number
}

variable "orc_ser_de_enable_padding" {
  description = " Set this to true to indicate that you want stripes to be padded to the HDFS block boundaries. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is false."
  type        = bool
}

variable "orc_ser_de_format_version" {
  description = "The version of the file to write. The possible values are V0_11 and V0_12. The default is V0_12."
  type        = string
}

variable "orc_ser_de_padding_tolerance" {
  description = " A float between 0 and 1 that defines the tolerance for block padding as a decimal fraction of stripe size. The default value is 0.05, which means 5 percent of stripe size. For the default values of 64 MiB ORC stripes and 256 MiB HDFS blocks, the default block padding tolerance of 5 percent reserves a maximum of 3.2 MiB for padding within the 256 MiB block. In such a case, if the available size within the block is more than 3.2 MiB, a new, smaller stripe is inserted to fit within that space. This ensures that no stripe crosses block boundaries and causes remote reads within a node-local task. Kinesis Data Firehose ignores this parameter when enable_padding is false."
  type        = number
}

variable "orc_ser_de_row_index_stride" {
  description = " The number of rows between index entries. The default is 10000 and the minimum is 1000."
  type        = number
}

variable "orc_ser_de_stripe_size_bytes" {
  description = "The number of bytes in each stripe. The default is 64 MiB and the minimum is 8 MiB."
  type        = number
}


variable "parquet_ser_de_block_size_bytes" {
  description = "The Hadoop Distributed File System (HDFS) block size. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 256 MiB and the minimum is 64 MiB. Kinesis Data Firehose uses this value for padding calculations. "
  type        = number
}

variable "parquet_ser_de_compression" {
  description = "The compression code to use over data blocks. The possible values are UNCOMPRESSED, SNAPPY, and GZIP, with the default being SNAPPY. Use SNAPPY for higher decompression speed. Use GZIP if the compression ratio is more important than speed."
  type        = string
}

variable "parquet_ser_de_enable_dictionary_compression" {
  description = "Indicates whether to enable dictionary compression."
  type        = bool
}

variable "parquet_ser_de_max_padding_bytes" {
  description = "The maximum amount of padding to apply. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 0."
  type        = number
}

variable "parquet_ser_de_page_size_bytes" {
  description = "The Parquet page size. Column chunks are divided into pages. A page is conceptually an indivisible unit (in terms of compression and encoding). The minimum value is 64 KiB and the default is 1 MiB."
  type        = number
}

variable "parquet_ser_de_writer_version" {
  description = "Indicates the version of row format to output. The possible values are V1 and V2. The default is V1."
  type        = string
}

variable "schema_configuration_version_id" {
  description = "Specifies the table version for the output data schema. Defaults to LATEST."
  type        = string
}

variable "dynamic_partitioning_enabled" {
  description = "Enables or disables dynamic partitioning. Defaults to false."
  type        = bool
}

variable "dynamic_partitioning_retry_duration" {
  description = "Total amount of seconds Firehose spends on retries. Valid values between 0 and 7200. Default is 300."
  type        = number
}

variable "processing_configuration_enabled" {
  description = "Enables or disables data processing."
  type        = bool
}
variable "processing_configuration_processors_type" {
  description = "The type of processor. Valid Values: RecordDeAggregation, Lambda, MetadataExtraction, AppendDelimiterToRecord. Validation is done against AWS SDK constants; so that values not explicitly listed may also work."
  type        = string
}

variable "processing_configuration_processors_parameter_name" {
  description = "Parameter name. Valid Values: LambdaArn, NumberOfRetries, MetadataExtractionQuery, JsonParsingEngine, RoleArn, BufferSizeInMBs, BufferIntervalInSeconds, SubRecordType, Delimiter. Validation is done against AWS SDK constants; so that values not explicitly listed may also work."
  type        = string
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

#variable for kinesis-datastream
variable "stream_mode" {
  description = <<-DOC
    shard_count:
        (Optional) The number of shards that the stream will use. If the stream_mode is PROVISIONED, this field is required. Amazon has guidelines for specifying the Stream size that should be referenced when creating a Kinesis stream. See Amazon Kinesis Streams for more.
    stream_mode_details:
        (Optional) Specifies the capacity mode of the stream. Must be either PROVISIONED or ON_DEMAND.
  DOC

  type = object({
    shard_count         = number
    stream_mode_details = string
  })

}

variable "shard_level_metrics" {
  description = " A list of shard-level CloudWatch metrics which can be enabled for the stream. See Monitoring with CloudWatch for more. Note that the value ALL should not be used; instead you should provide an explicit list of metrics you wish to enable."
  type        = list(string)
}

#variable for Glue database and table
variable "create_table_default_permission" {
  description = "Creates a set of default permissions on the table for principals."
  type        = any
}

variable "table_type" {
  description = "Type of this table (EXTERNAL_TABLE, VIRTUAL_VIEW, etc.). While optional, some Athena DDL queries such as ALTER TABLE and SHOW CREATE TABLE will fail if this argument is empty"
  type        = string
}

variable "parameters" {
  description = "Properties associated with this table, as a list of key-value pairs"
  type        = map(string)
}

variable "partition_keys" {
  description = "Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys"
  type        = list(map(string))
}

variable "storage_descriptor" {
  description = "Configuration block for information about the physical storage of this table"
  type        = list(any)
}

#variables for lambda

variable "vpc_id_name" {
  type        = string
  description = "The name given in the parameter store for the vpc id"
}

variable "subnet_id1_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 1"
}

#variables for Lambda_function
variable "function_name" {
  description = "Unique name for your Lambda Function"
  type        = string
}

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

variable "local_zip_source_directory" {
  description = "Package entire contents of this directory into the archive"
  type        = string
}

#variables for security_group
variable "lambda_cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "lambda_cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "lambda_sg_name" {
  description = "name of the security group"
  type        = string
}

#variables for aws_lambda_iam_role
variable "iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}