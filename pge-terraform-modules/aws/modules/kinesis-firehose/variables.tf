#variables for kinesis firehose
variable "name" {
  description = "A name to identify the stream. This is unique to the AWS account and region the Stream is created in."
  type        = string
  validation {
    condition = alltrue([
      length(var.name) <= 64,
      length(var.name) >= 1,
      can(regex("[a-zA-Z0-9_.-]+", var.name))
    ])
    error_message = "Error! delivery stream name has to be lenght of minimum:1, maximum:64 and pattern: [a-zA-Z0-9_.-]+ !"
  }
}

variable "destination" {
  description = " This is the destination to where the data is delivered. The only options are  extended_s3, redshift, elasticsearch, splunk, and http_endpoint."
  type        = string
  validation {
    condition     = contains(["extended_s3", "redshift", "elasticsearch", "splunk", "http_endpoint"], var.destination)
    error_message = "Error! Please provide valid values for destination extended_s3, redshift, elasticsearch, splunk, http_endpoint!"
  }
}

variable "kinesis_source_server_side_encryption" {
  description = <<-DOC
   kinesis_stream_arn:
    "The kinesis stream used as the source of the firehose delivery stream."
   role_arn:
    "The ARN of the role that provides access to the source Kinesis stream."
   key_arn : 
     "Amazon Resource Name (ARN) of the encryption key. Required when key_type is CUSTOMER_MANAGED_CMK."
  DOC
  type = object({
    kinesis_stream_arn = string
    role_arn           = string
    key_arn            = string
  })
  default = {
    kinesis_stream_arn = null
    role_arn           = null
    key_arn            = null
  }
  validation {
    condition     = var.kinesis_source_server_side_encryption.kinesis_stream_arn != null && var.kinesis_source_server_side_encryption.kinesis_stream_arn != null && var.kinesis_source_server_side_encryption.key_arn != null ? false : true
    error_message = "Error! Kinesis source configuration conflicts with server side encryption, if kinesis source configuration is used, please do not use server side encryption block.!"
  }
  validation {
    condition     = var.kinesis_source_server_side_encryption.kinesis_stream_arn != null ? can(regex("^arn:aws:kinesis:\\w+", var.kinesis_source_server_side_encryption.kinesis_stream_arn)) : true
    error_message = "Error! Please provide kinesis stream arn in form of arn:aws:kinesis:xxxxxx!"
  }
  validation {
    condition     = var.kinesis_source_server_side_encryption.role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.kinesis_source_server_side_encryption.role_arn)) : true
    error_message = "Error! Please provide role arn in form of arn:aws:iam::xxxxxx !"
  }
  validation {
    condition     = var.kinesis_source_server_side_encryption.key_arn != null ? can(regex("^arn:aws:kms:\\w+", var.kinesis_source_server_side_encryption.key_arn)) : true
    error_message = "Error! Please provide server side encryption key arn in form of arn:aws:kms:xxxxxx !"
  }
}

#variables for extended_s3_configuration
variable "extended_s3_configuration" {
  description = <<-DOC
   role_arn :
    The ARN of the AWS credentials.
   bucket_arn : 
    The ARN of the S3 bucket
   kms_key_arn :
    Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used. 
   s3_backup_mode : 
    The Amazon S3 backup mode. Valid values are Disabled and Enabled. Default value is Disabled.
   prefix :
    The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket
   buffer_size : 
    Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher.
   buffer_interval :
    Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300.
   compression_format : 
    The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP_SNAPPY.
   error_output_prefix : 
    Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects.
   log_group_name : 
    The CloudWatch group name for logging. This value is required if enabled is true.
   log_stream_name : 
    The CloudWatch log stream name for logging. This value is required if enabled is true.
   data_format_conversion_enabled : 
    Defaults to true. Set it to false if you want to disable format conversion while preserving the configuration details.
   s3_backup_role_arn :
    The ARN of the AWS credentials.
   s3_backup_bucket_arn : 
    The ARN of the S3 bucket
   s3_backup_kms_key_arn :
    Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used.
   s3_backup_prefix :
    The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket
   s3_backup_buffer_size : 
    Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher.
   s3_backup_buffer_interval :
    Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300.
   s3_backup_compression_format :
    The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP_SNAPPY.
   s3_backup_error_output_prefix : 
    Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects.
   s3_backup_log_group_name : 
    The CloudWatch group name for logging. This value is required if enabled is true.
   s3_backup_log_stream_name : 
    The CloudWatch log stream name for logging. This value is required if enabled is true.  
   hive_json_ser_de_timestamp_formats : 
    A list of how you want Kinesis Data Firehose to parse the date and time stamps that may be present in your input data JSON. To specify these format strings, follow the pattern syntax of JodaTime's DateTimeFormat format strings. For more information, see Class DateTimeFormat. You can also use the special value millis to parse time stamps in epoch milliseconds. If you don't specify a format, Kinesis Data Firehose uses java.sql.Timestamp::valueOf by default.
   open_x_json_ser_de_case_insensitive :
    When set to true, which is the default, Kinesis Data Firehose converts JSON keys to lowercase before deserializing them.
   open_x_json_ser_de_column_to_json_key_mappings : 
    A map of column names to JSON keys that aren't identical to the column names. This is useful when the JSON contains keys that are Hive keywords. For example, timestamp is a Hive keyword. If you have a JSON key named timestamp, set this parameter to { ts = 'timestamp' } to map this key to a column named ts.
   open_x_json_ser_de_convert_dots_in_json_keys_to_underscores :
    When set to true, specifies that the names of the keys include dots and that you want Kinesis Data Firehose to replace them with underscores. This is useful because Apache Hive does not allow dots in column names. For example, if the JSON contains a key whose name is 'a.b', you can define the column name to be 'a_b' when using this option. Defaults to false.
   orc_ser_de_block_size_bytes : 
    The Hadoop Distributed File System (HDFS) block size. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 256 MiB and the minimum is 64 MiB. Kinesis Data Firehose uses this value for padding calculations.
   orc_ser_de_bloom_filter_columns : 
    A list of column names for which you want Kinesis Data Firehose to create bloom filters.
   orc_ser_de_bloom_filter_false_positive_probability
    The Bloom filter false positive probability (FPP). The lower the FPP, the bigger the Bloom filter. The default value is 0.05, the minimum is 0, and the maximum is 1.
   orc_ser_de_compression : 
    The compression code to use over data blocks. The possible values are UNCOMPRESSED, SNAPPY, and GZIP, with the default being SNAPPY. Use SNAPPY for higher decompression speed. Use GZIP if the compression ratio is more important than speed.
   orc_ser_de_dictionary_key_threshold
    A float that represents the fraction of the total number of non-null rows. To turn off dictionary encoding, set this fraction to a number that is less than the number of distinct keys in a dictionary. To always use dictionary encoding, set this threshold to 1.
   orc_ser_de_enable_padding : 
    Set this to true to indicate that you want stripes to be padded to the HDFS block boundaries. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is false.
   orc_ser_de_format_version : 
    The version of the file to write. The possible values are V0_11 and V0_12. The default is V0_12.
   orc_ser_de_padding_tolerance : 
    A float between 0 and 1 that defines the tolerance for block padding as a decimal fraction of stripe size. The default value is 0.05, which means 5 percent of stripe size. For the default values of 64 MiB ORC stripes and 256 MiB HDFS blocks, the default block padding tolerance of 5 percent reserves a maximum of 3.2 MiB for padding within the 256 MiB block. In such a case, if the available size within the block is more than 3.2 MiB, a new, smaller stripe is inserted to fit within that space. This ensures that no stripe crosses block boundaries and causes remote reads within a node-local task. Kinesis Data Firehose ignores this parameter when enable_padding is false.
   orc_ser_de_row_index_stride : 
    The number of rows between index entries. The default is 10000 and the minimum is 1000.
   orc_ser_de_stripe_size_bytes : 
    The number of bytes in each stripe. The default is 64 MiB and the minimum is 8 MiB.
   parquet_ser_de_block_size_bytes :
    The Hadoop Distributed File System (HDFS) block size. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 256 MiB and the minimum is 64 MiB. Kinesis Data Firehose uses this value for padding calculations. 
   parquet_ser_de_compression :
    The compression code to use over data blocks. The possible values are UNCOMPRESSED, SNAPPY, and GZIP, with the default being SNAPPY. Use SNAPPY for higher decompression speed. Use GZIP if the compression ratio is more important than speed.
   parquet_ser_de__enable_dictionary_compression
    Indicates whether to enable dictionary compression.
   parquet_ser_de__max_padding_bytes : 
    The maximum amount of padding to apply. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 0.
   parquet_ser_de__page_size_bytes : 
    The Parquet page size. Column chunks are divided into pages. A page is conceptually an indivisible unit (in terms of compression and encoding). The minimum value is 64 KiB and the default is 1 MiB.
   parquet_ser_de_writer_version : 
    Indicates the version of row format to output. The possible values are V1 and V2. The default is V1.
   schema_configuration_database_name :
    Specifies the name of the AWS Glue database that contains the schema for the output data.
   schema_configuration_role_arn :
    The role that Kinesis Data Firehose can use to access AWS Glue. This role must be in the same account you use for Kinesis Data Firehose. Cross-account roles aren't allowed.
   schema_configuration_table_name :
    Specifies the AWS Glue table that contains the column information that constitutes your data schema.
   schema_configuration_catalog_id : 
    The ID of the AWS Glue Data Catalog. If you don't supply this, the AWS account ID is used by default. 
   schema_configuration_region : 
    If you don't specify an AWS Region, the default is the current region.
   schema_configuration_version_id : 
    Specifies the table version for the output data schema. Defaults to LATEST.
   deserializer :                                            
     Provide value either 'hive_json_ser_de' or 'open_x_json_ser_de' to select respective block to execute.
   serializer :
    Provide value either 'orc_ser_de' or ;parquet_ser_de' to select respective block to execute.
   dynamic_partitioning_enabled :
    Enables or disables dynamic partitioning. Defaults to false.
   dynamic_partitioning_retry_duration : 
    Total amount of seconds Firehose spends on retries. Valid values between 0 and 7200. Default is 300.  
   processing_configuration : 
    The data processing configuration
   processing_configuration_enabled : 
    Enables or disables data processing.
   processors :   
     Array of data processors.    
  DOC

  type = object({
    role_arn                                                    = string
    bucket_arn                                                  = string
    kms_key_arn                                                 = string
    s3_backup_mode                                              = string
    prefix                                                      = string
    buffer_size                                                 = number
    buffer_interval                                             = number
    compression_format                                          = string
    error_output_prefix                                         = string
    log_group_name                                              = string
    log_stream_name                                             = string
    data_format_conversion_enabled                              = bool
    s3_backup_role_arn                                          = string
    s3_backup_bucket_arn                                        = string
    s3_backup_kms_key_arn                                       = string
    s3_backup_prefix                                            = string
    s3_backup_buffer_size                                       = number
    s3_backup_buffer_interval                                   = number
    s3_backup_compression_format                                = string
    s3_backup_error_output_prefix                               = string
    s3_backup_log_group_name                                    = string
    s3_backup_log_stream_name                                   = string
    hive_json_ser_de_timestamp_formats                          = list(string)
    open_x_json_ser_de_case_insensitive                         = bool
    open_x_json_ser_de_column_to_json_key_mappings              = map(string)
    open_x_json_ser_de_convert_dots_in_json_keys_to_underscores = bool
    orc_ser_de_block_size_bytes                                 = number
    orc_ser_de_bloom_filter_columns                             = list(string)
    orc_ser_de_bloom_filter_false_positive_probability          = number
    orc_ser_de_compression                                      = string
    orc_ser_de_dictionary_key_threshold                         = number
    orc_ser_de_enable_padding                                   = bool
    orc_ser_de_format_version                                   = string
    orc_ser_de_padding_tolerance                                = number
    orc_ser_de_row_index_stride                                 = number
    orc_ser_de_stripe_size_bytes                                = number
    parquet_ser_de_block_size_bytes                             = number
    parquet_ser_de_compression                                  = string
    parquet_ser_de_enable_dictionary_compression                = bool
    parquet_ser_de_max_padding_bytes                            = number
    parquet_ser_de_writer_version                               = string
    parquet_ser_de_page_size_bytes                              = number
    schema_configuration_database_name                          = string
    schema_configuration_role_arn                               = string
    schema_configuration_table_name                             = string
    schema_configuration_catalog_id                             = string
    schema_configuration_region                                 = string
    schema_configuration_version_id                             = string
    deserializer                                                = string
    serializer                                                  = string
    dynamic_partitioning_enabled                                = bool
    dynamic_partitioning_retry_duration                         = number
    processing_configuration = object({
      enabled    = bool
      processors = list(any)
    })
  })

  default = {
    role_arn                                                    = null
    bucket_arn                                                  = null
    kms_key_arn                                                 = null
    s3_backup_mode                                              = "Disabled"
    prefix                                                      = null
    buffer_size                                                 = 5
    buffer_interval                                             = 300
    compression_format                                          = "UNCOMPRESSED"
    error_output_prefix                                         = null
    log_group_name                                              = null
    log_stream_name                                             = null
    data_format_conversion_enabled                              = true
    s3_backup_role_arn                                          = null
    s3_backup_bucket_arn                                        = null
    s3_backup_kms_key_arn                                       = null
    s3_backup_prefix                                            = null
    s3_backup_buffer_size                                       = 5
    s3_backup_buffer_interval                                   = 300
    s3_backup_compression_format                                = "UNCOMPRESSED"
    s3_backup_error_output_prefix                               = null
    s3_backup_log_group_name                                    = null
    s3_backup_log_stream_name                                   = null
    hive_json_ser_de_timestamp_formats                          = []
    open_x_json_ser_de_case_insensitive                         = true
    open_x_json_ser_de_column_to_json_key_mappings              = {}
    open_x_json_ser_de_convert_dots_in_json_keys_to_underscores = false
    orc_ser_de_block_size_bytes                                 = 67108864
    orc_ser_de_bloom_filter_columns                             = []
    orc_ser_de_bloom_filter_false_positive_probability          = 0.05
    orc_ser_de_compression                                      = "SNAPPY"
    orc_ser_de_dictionary_key_threshold                         = 1
    orc_ser_de_enable_padding                                   = false
    orc_ser_de_format_version                                   = "V0_12"
    orc_ser_de_padding_tolerance                                = 0.05
    orc_ser_de_row_index_stride                                 = 10000
    orc_ser_de_stripe_size_bytes                                = 8388608
    parquet_ser_de_block_size_bytes                             = 268435456
    parquet_ser_de_compression                                  = "SNAPPY"
    parquet_ser_de_enable_dictionary_compression                = false
    parquet_ser_de_max_padding_bytes                            = 0
    parquet_ser_de_writer_version                               = "V1"
    parquet_ser_de_page_size_bytes                              = 65536
    schema_configuration_database_name                          = null
    schema_configuration_role_arn                               = null
    schema_configuration_table_name                             = null
    schema_configuration_catalog_id                             = null
    schema_configuration_region                                 = null
    schema_configuration_version_id                             = "LATEST"
    deserializer                                                = "hive_json_ser_de"
    serializer                                                  = "orc_ser_de"
    dynamic_partitioning_enabled                                = false
    dynamic_partitioning_retry_duration                         = 300
    processing_configuration = {
      enabled    = false
      processors = []
    }
  }
  validation {
    condition     = var.extended_s3_configuration.bucket_arn != null && var.extended_s3_configuration.kms_key_arn == null ? false : true
    error_message = "Error! When extended_s3 block is used kms_key arn cannot be null, please provide valid value!"
  }
  validation {
    condition     = var.extended_s3_configuration.s3_backup_mode == "Enabled" && var.extended_s3_configuration.s3_backup_kms_key_arn == null ? false : true
    error_message = "Error! When s3 back up configuration block is used kms_key_arn cannot be null, please provide valid value!"
  }
  validation {
    condition     = var.extended_s3_configuration.bucket_arn != null && var.extended_s3_configuration.log_group_name == null && var.extended_s3_configuration.log_stream_name == null ? false : true
    error_message = "Error! Log group name and log stream name are required!"
  }
  validation {
    condition     = var.extended_s3_configuration.s3_backup_mode == "Enabled" && var.extended_s3_configuration.s3_backup_log_group_name == null && var.extended_s3_configuration.s3_backup_log_stream_name == null ? false : true
    error_message = "Error! Log group name and log stream name are required!"
  }
  validation {
    condition     = contains(["hive_json_ser_de", "open_x_json_ser_de"], var.extended_s3_configuration.deserializer)
    error_message = "Error! Choose one of hive_json_ser_de or open_x_json_ser_de!"
  }
  validation {
    condition     = contains(["orc_ser_de", "parquet_ser_de"], var.extended_s3_configuration.serializer)
    error_message = "Error! Chosose one of orc_ser_de or  parquet_ser_de!"
  }
  validation {
    condition     = var.extended_s3_configuration.role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.extended_s3_configuration.role_arn)) : true
    error_message = "Error! Please provide role arn in form of arn:aws:iam::xxxxxx !"
  }
  validation {
    condition     = var.extended_s3_configuration.bucket_arn != null ? can(regex("^arn:aws:s3:::\\w+", var.extended_s3_configuration.bucket_arn)) : true
    error_message = "Error! Please provide bucket arn in form of arn:aws:s3:::xxxxxx !"
  }
  validation {
    condition     = var.extended_s3_configuration.kms_key_arn != null ? can(regex("^arn:aws:kms:\\w+", var.extended_s3_configuration.kms_key_arn)) : true
    error_message = "Error! Please provide kms key arn in form of arn:aws:kms:xxxxxx !"
  }
  validation {
    condition     = contains(["Disabled", "Enabled"], var.extended_s3_configuration.s3_backup_mode)
    error_message = "Error! Valid values for s3_backup_mode are Disabled and Enabled!"
  }
  validation {
    condition     = var.extended_s3_configuration.prefix != null ? length(var.extended_s3_configuration.prefix) >= 0 && length(var.extended_s3_configuration.prefix) <= 1024 : true
    error_message = "Error! prefix length - minimum 0 maximum 1024!"
  }
  validation {
    condition     = contains(["GZIP", "ZIP", "Snappy", "HADOOP_SNAPPY", "UNCOMPRESSED"], var.extended_s3_configuration.compression_format)
    error_message = "Error! Valid values for compression_format are  UNCOMPRESSED, GZIP, ZIP, Snappy, & HADOOP_SNAPPY!"
  }
  validation {
    condition     = var.extended_s3_configuration.s3_backup_role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.extended_s3_configuration.s3_backup_role_arn)) : true
    error_message = "Error! Please provide role arn in form of arn:aws:iam::xxxxxx !"
  }
  validation {
    condition     = var.extended_s3_configuration.s3_backup_bucket_arn != null ? can(regex("^arn:aws:s3:::\\w+", var.extended_s3_configuration.s3_backup_bucket_arn)) : true
    error_message = "Error! Please provide bucket arn in form of arn:aws:s3:::xxxxxx !"
  }
  validation {
    condition     = var.extended_s3_configuration.s3_backup_kms_key_arn != null ? can(regex("^arn:aws:kms:\\w+", var.extended_s3_configuration.s3_backup_kms_key_arn)) : true
    error_message = "Error! Please provide kms key arn in form of arn:aws:kms:xxxxxx !"
  }
  validation {
    condition     = var.extended_s3_configuration.s3_backup_prefix != null ? length(var.extended_s3_configuration.s3_backup_prefix) >= 0 && length(var.extended_s3_configuration.s3_backup_prefix) <= 1024 : true
    error_message = "Error! s3_backup_prefix length - minimum 0 maximum 1024!"
  }
  validation {
    condition     = contains(["GZIP", "ZIP", "Snappy", "HADOOP_SNAPPY", "UNCOMPRESSED"], var.extended_s3_configuration.s3_backup_compression_format)
    error_message = "Error! Valid values for compression_format are  UNCOMPRESSED, GZIP, ZIP, Snappy, & HADOOP_SNAPPY!"
  }
  validation {
    condition     = alltrue([var.extended_s3_configuration.orc_ser_de_block_size_bytes >= 64])
    error_message = "Error! minimum value of block_size_bytes is 64 MiB!"
  }
  validation {
    condition     = alltrue([var.extended_s3_configuration.orc_ser_de_bloom_filter_false_positive_probability >= 0 && var.extended_s3_configuration.orc_ser_de_bloom_filter_false_positive_probability <= 1])
    error_message = "Error! bloom_filter_false_positive_probability, the minimum is 0, and the maximum is 1!"
  }
  validation {
    condition     = contains(["GZIP", "SNAPPY", "UNCOMPRESSED"], var.extended_s3_configuration.orc_ser_de_compression)
    error_message = "Error! Valid values for compression are  UNCOMPRESSED, GZIP and SNAPPY!"
  }
  validation {
    condition     = contains(["V0_11", "V0_12"], var.extended_s3_configuration.orc_ser_de_format_version)
    error_message = "Error! format_version possible values are V0_11 and V0_12!"
  }
  validation {
    condition     = alltrue([var.extended_s3_configuration.orc_ser_de_padding_tolerance >= 0 && var.extended_s3_configuration.orc_ser_de_padding_tolerance <= 1])
    error_message = "Error! Value float between 0 and 1!"
  }
  validation {
    condition     = alltrue([var.extended_s3_configuration.orc_ser_de_row_index_stride >= 10000])
    error_message = "Error! row_index_stride, the minimum is 10000!"
  }
  validation {
    condition     = alltrue([var.extended_s3_configuration.orc_ser_de_stripe_size_bytes >= 8])
    error_message = "Error! stripe_size_bytes, the minimum is 8!"
  }
  validation {
    condition     = contains(["V1", "V2"], var.extended_s3_configuration.parquet_ser_de_writer_version)
    error_message = "Error! writer_version possible values are V1 and V2!"
  }
  validation {
    condition     = contains(["UNCOMPRESSED", "SNAPPY", "GZIP"], var.extended_s3_configuration.parquet_ser_de_compression)
    error_message = "Error! Please provide valid values for parquet_ser_de compression - UNCOMPRESSED, SNAPPY and GZIP!"
  }
  validation {
    condition     = alltrue([var.extended_s3_configuration.parquet_ser_de_block_size_bytes >= 64])
    error_message = "Error! Please provide valid value for parquet_ser_de block_size_bytes - minimum is 64 Mi!"
  }
  validation {
    condition     = alltrue([var.extended_s3_configuration.parquet_ser_de_page_size_bytes >= 64])
    error_message = "Error! Please provide valid value for parquet_ser_de page_size_bytes - minimum value is 64 KiB!"
  }
  validation {
    condition     = var.extended_s3_configuration.schema_configuration_role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.extended_s3_configuration.schema_configuration_role_arn)) : true
    error_message = "Error! Please provide role arn in form of arn:aws:iam::xxxxx!"
  }
  validation {
    condition     = alltrue([var.extended_s3_configuration.dynamic_partitioning_retry_duration >= 0 && var.extended_s3_configuration.dynamic_partitioning_retry_duration <= 7200])
    error_message = "Error! retry_duration valid values are between 0 and 7200 "
  }
}

#variables for redshift configuration
variable "redshift_configuration" {
  description = <<-DOC
   cluster_jdbcurl :
    The jdbcurl of the redshift cluster.
   username :
    The username that the firehose delivery stream will assume. It is strongly recommended that the username and password provided is used exclusively for Amazon Kinesis Firehose purposes, and that the permissions for the account are restricted for Amazon Redshift INSERT permissions.
   password :
    The password for the username above.
   role_arn :
    The arn of the role the stream assumes. 
   data_table_name : 
    The name of the table in the redshift cluster that the s3 bucket will copy to. 
   s3_backup_mode : 
    The Amazon S3 backup mode. Valid values are Disabled and Enabled. Default value is Disabled.
   retry_duration : 
    The length of time during which Firehose retries delivery after a failure, starting from the initial request and including the first attempt. The default value is 3600 seconds (60 minutes). Firehose does not retry if the value of DurationInSeconds is 0 (zero) or if the first delivery attempt takes longer than the current value.
   copy_options :
    Copy options for copying the data from the s3 intermediate bucket into redshift, for example to change the default delimiter. For valid values, see the AWS documentation
   data_table_columns : 
    The data table columns that will be targeted by the copy command.
   log_group_name : 
    The CloudWatch group name for logging. This value is required if enabled is true.
   log_stream_name :
    The CloudWatch log stream name for logging. This value is required if enabled is true.
   kms_key_arn :
    Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used. 
   prefix :
    The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket
   buffer_size : 
    Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher.
   buffer_interval :
    Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300.
   compression_format :
    The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP_SNAPPY.
   error_output_prefix : 
    Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects.
   s3_backup_role_arn :
    The ARN of the AWS credentials.
   s3_backup_bucket_arn : 
    The ARN of the S3 bucket
   s3_backup_kms_key_arn :
    Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used.
   s3_backup_prefix :
    The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket
   s3_backup_buffer_size : 
    Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher.
   s3_backup_buffer_interval :
    Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300.
   s3_backup_compression_format :
    The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP_SNAPPY.
   s3_backup_error_output_prefix : 
    Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects.
   s3_backup_log_group_name : 
    The CloudWatch group name for logging. This value is required if enabled is true.
   bucket_arn : 
    The ARN of the S3 bucket
   s3_backup_log_stream_name : 
    The CloudWatch log stream name for logging. This value is required if enabled is true. 
   processing_configuration : 
    The data processing configuration
   processing_configuration_enabled : 
    Enables or disables data processing.
   processors :   
     Array of data processors.
  DOC
  type = object({
    cluster_jdbcurl               = string
    username                      = string
    password                      = string
    role_arn                      = string
    data_table_name               = string
    s3_backup_mode                = string
    retry_duration                = number
    copy_options                  = string
    data_table_columns            = string
    log_group_name                = string
    log_stream_name               = string
    s3_backup_role_arn            = string
    s3_backup_bucket_arn          = string
    s3_backup_kms_key_arn         = string
    s3_backup_prefix              = string
    s3_backup_buffer_size         = number
    s3_backup_buffer_interval     = number
    s3_backup_compression_format  = string
    s3_backup_error_output_prefix = string
    s3_backup_log_group_name      = string
    s3_backup_log_stream_name     = string
    processing_configuration = object({
      enabled    = bool
      processors = list(any)
    })
    s3_configuration = object({
      role_arn            = string
      bucket_arn          = string
      kms_key_arn         = string
      prefix              = string
      buffer_size         = number
      buffer_interval     = number
      compression_format  = string
      error_output_prefix = string
      log_group_name      = string
      log_stream_name     = string
    })
  })
  default = {
    cluster_jdbcurl               = null
    username                      = null
    password                      = null
    role_arn                      = null
    data_table_name               = null
    s3_backup_mode                = "Disabled"
    retry_duration                = 3600
    copy_options                  = null
    data_table_columns            = null
    log_group_name                = null
    log_stream_name               = null
    s3_backup_role_arn            = null
    s3_backup_bucket_arn          = null
    s3_backup_kms_key_arn         = null
    s3_backup_prefix              = null
    s3_backup_buffer_size         = 5
    s3_backup_buffer_interval     = 300
    s3_backup_compression_format  = "UNCOMPRESSED"
    s3_backup_error_output_prefix = null
    s3_backup_log_group_name      = null
    s3_backup_log_stream_name     = null
    processing_configuration = {
      enabled    = false
      processors = []
    }
    s3_configuration = {
      role_arn            = null
      bucket_arn          = null
      kms_key_arn         = null
      prefix              = null
      buffer_size         = 5
      buffer_interval     = 300
      compression_format  = "UNCOMPRESSED"
      error_output_prefix = null
      log_group_name      = null
      log_stream_name     = null
    }
  }
  validation {
    condition     = var.redshift_configuration.s3_backup_mode == "Enabled" && var.redshift_configuration.s3_backup_kms_key_arn == null ? false : true
    error_message = "Error! When s3 back up configuration block is used kms_key arn cannot be null, please provide valid values!"
  }
  validation {
    condition     = var.redshift_configuration.role_arn != null && var.redshift_configuration.log_group_name == null && var.redshift_configuration.log_stream_name == null ? false : true
    error_message = "Error! Log group name and log stream name are required!"
  }
  validation {
    condition     = var.redshift_configuration.s3_backup_mode == "Enabled" && var.redshift_configuration.s3_backup_log_group_name == null && var.redshift_configuration.s3_backup_log_stream_name == null ? false : true
    error_message = "Error! Log group name and log stream name are required!"
  }
  validation {
    condition     = var.redshift_configuration.cluster_jdbcurl != null ? can(regex("^jdbc:\\w+", var.redshift_configuration.cluster_jdbcurl)) : true
    error_message = "Error! Please provide  cluster_jdbcurl in form of jdbc:xxxxxx!"
  }
  validation {
    condition     = var.redshift_configuration.username != null ? length(var.redshift_configuration.username) >= 1 && length(var.redshift_configuration.username) <= 512 : true
    error_message = "Error! Please provide valid value for username, minimum length 1  maximum length 512!"
  }
  validation {
    condition     = var.redshift_configuration.password != null ? length(var.redshift_configuration.password) >= 6 && length(var.redshift_configuration.password) <= 100 : true
    error_message = "Error! Please provide valid password,  minimum length 6  maximum length 512!"
  }
  validation {
    condition     = contains(["Disabled", "Enabled"], var.redshift_configuration.s3_backup_mode)
    error_message = "Error! Valid values for s3_backup_mode are Disabled and Enabled!"
  }
  validation {
    condition     = contains(["GZIP", "ZIP", "Snappy", "HADOOP_SNAPPY", "UNCOMPRESSED"], var.redshift_configuration.s3_backup_compression_format)
    error_message = "Error! Valid values for compression_format are  UNCOMPRESSED, GZIP, ZIP, Snappy, & HADOOP_SNAPPY!"
  }
  validation {
    condition     = var.redshift_configuration.role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.redshift_configuration.role_arn)) : true
    error_message = "Error! Please provide role arn in form of arn:aws:iam::xxxxxx!"
  }
  validation {
    condition     = var.redshift_configuration.s3_backup_role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.redshift_configuration.s3_backup_role_arn)) : true
    error_message = "Error! Please provide role arn in form of arn:aws:iam::xxxxxx!"
  }
  validation {
    condition     = var.redshift_configuration.s3_backup_bucket_arn != null ? can(regex("^arn:aws:s3:::\\w+", var.redshift_configuration.s3_backup_bucket_arn)) : true
    error_message = "Error! Please provide bucket arn in form of arn:aws:s3:::xxxxxx!"
  }
  validation {
    condition     = var.redshift_configuration.s3_backup_kms_key_arn != null ? can(regex("^arn:aws:kms:\\w+", var.redshift_configuration.s3_backup_kms_key_arn)) : true
    error_message = "Error! Please provide key arn in form of arn:aws:kms:xxxxxx!"
  }
}

#variables for elasticsearch_configuration 
variable "elasticsearch_configuration" {
  description = <<-DOC
   index_name :
    The Elasticsearch index name.
   role_arn :
    The ARN of the IAM role to be assumed by Firehose for calling the Amazon ES Configuration API and for indexing documents. The pattern needs to be arn:.*.
   domain_arn :
    The ARN of the Amazon ES domain. The IAM role must have permission for DescribeElasticsearchDomain, DescribeElasticsearchDomains, and DescribeElasticsearchDomainConfig after assuming RoleARN. The pattern needs to be arn:.*. Conflicts with cluster_endpoint.
   cluster_endpoint :
    The endpoint to use when communicating with the cluster. Conflicts with domain_arn.
   buffering_interval :
    Buffer incoming data for the specified period of time, in seconds between 60 to 900, before delivering it to the destination. The default value is 300s.
   buffering_size :
    Buffer incoming data to the specified size, in MBs between 1 to 100, before delivering it to the destination. The default value is 5MB.
   index_rotation_period : 
    index_rotation_periodThe Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data. Valid values are NoRotation, OneHour, OneDay, OneWeek, and OneMonth. The default value is OneDay.
   s3_backup_mode : 
    Defines how documents should be delivered to Amazon S3. Valid values are FailedDocumentsOnly and AllDocuments. Default value is FailedDocumentsOnly.
   type_name :
    The Elasticsearch type name with maximum length of 100 characters.
   vpc_config_subnet_ids :
    A list of subnet IDs to associate with Kinesis Firehose.
   vpc_config_security_group_ids :
    A list of security group IDs to associate with Kinesis Firehose. 
   vpc_config_role_arn :
    The ARN of the IAM role to be assumed by Firehose for calling the Amazon EC2 configuration API and for creating network interfaces. Make sure role has necessary IAM permissions
   retry_duration : 
    Total amount of seconds Firehose spends on retries. Valid values between 0 and 7200. Default is 300.
   log_group_name : 
    The CloudWatch group name for logging. This value is required if enabled is true.
   log_stream_name :
    The CloudWatch log stream name for logging. This value is required if enabled is true.
   processing_configuration : 
    The data processing configuration
   processing_configuration_enabled : 
    Enables or disables data processing.    
   processors :   
     Array of data processors.   
   Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300.
   compression_format :
    The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP_SNAPPY.
   error_output_prefix : 
    Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects. 
  DOC

  type = object({
    index_name                    = string
    role_arn                      = string
    domain_arn                    = string
    cluster_endpoint              = string
    buffering_interval            = number
    buffering_size                = number
    index_rotation_period         = string
    s3_backup_mode                = string
    type_name                     = string
    vpc_config_subnet_ids         = list(string)
    vpc_config_security_group_ids = list(string)
    vpc_config_role_arn           = string
    retry_duration                = string
    log_group_name                = string
    log_stream_name               = string
    processing_configuration = object({
      enabled    = bool
      processors = list(any)
    })
    s3_configuration = object({
      role_arn            = string
      bucket_arn          = string
      kms_key_arn         = string
      prefix              = string
      buffer_size         = number
      buffer_interval     = number
      compression_format  = string
      error_output_prefix = string
      log_group_name      = string
      log_stream_name     = string
    })
  })
  default = {
    index_name                    = null
    role_arn                      = null
    domain_arn                    = null
    cluster_endpoint              = null
    buffering_interval            = 300
    buffering_size                = 5
    index_rotation_period         = "OneDay"
    s3_backup_mode                = "FailedDocumentsOnly"
    type_name                     = null
    vpc_config_subnet_ids         = []
    vpc_config_security_group_ids = []
    vpc_config_role_arn           = null
    retry_duration                = 300
    log_group_name                = null
    log_stream_name               = null
    processing_configuration = {
      enabled    = false
      processors = []
    }
    s3_configuration = {
      role_arn            = null
      bucket_arn          = null
      kms_key_arn         = null
      prefix              = null
      buffer_size         = 5
      buffer_interval     = 300
      compression_format  = "UNCOMPRESSED"
      error_output_prefix = null
      log_group_name      = null
      log_stream_name     = null
    }
  }
  validation {
    condition     = var.elasticsearch_configuration.role_arn != null && var.elasticsearch_configuration.log_group_name == null && var.elasticsearch_configuration.log_stream_name == null ? false : true
    error_message = "Error! Log group name and log stream name are required!"
  }
  validation {
    condition     = var.elasticsearch_configuration.index_name != null ? length(var.elasticsearch_configuration.index_name) >= 1 && length(var.elasticsearch_configuration.index_name) <= 80 : true
    error_message = "Error! Please provide valid index name, minimum length 1  maximum  length 80!"
  }
  validation {
    condition     = var.elasticsearch_configuration.type_name != null ? length(var.elasticsearch_configuration.type_name) >= 0 && length(var.elasticsearch_configuration.type_name) <= 100 : true
    error_message = "Error! Please provide valid type name, minimum length 0  maximum length 100!"
  }
  validation {
    condition = alltrue([
      (var.elasticsearch_configuration.domain_arn != null ? var.elasticsearch_configuration.cluster_endpoint == null : true),
      (var.elasticsearch_configuration.cluster_endpoint != null ? var.elasticsearch_configuration.domain_arn == null : true)
    ])
    error_message = "Error! domain_arn conflicts with cluster_endpoint!"
  }
  validation {
    condition     = var.elasticsearch_configuration.domain_arn != null ? can(regex("^arn:\\w+", var.elasticsearch_configuration.domain_arn)) : true
    error_message = "Error! Please provide domain arn in form of arn:xxxxxx!"
  }
  validation {
    condition     = var.elasticsearch_configuration.buffering_interval >= 60 && var.elasticsearch_configuration.buffering_interval <= 900
    error_message = "Error! elasticsearch_buffering_interval, valid values in seconds between 60 to 900!"
  }
  validation {
    condition     = alltrue([var.elasticsearch_configuration.buffering_size >= 1 && var.elasticsearch_configuration.buffering_size <= 100])
    error_message = "Error! elasticsearch_buffering_size, valid values in MBs between 1 to 100!"
  }
  validation {
    condition     = contains(["OneDay", "NoRotation", "OneHour", "OneDay", "OneWeek", "OneMonth"], var.elasticsearch_configuration.index_rotation_period)
    error_message = "Error! Valid values for index_rotation_period are NoRotation, OneHour, OneDay, OneWeek, and OneMonth!"
  }
  validation {
    condition     = contains(["FailedDocumentsOnly", "AllDocuments"], var.elasticsearch_configuration.s3_backup_mode)
    error_message = "Error! elasticsearch_s3_backup_mode, valid values are FailedDocumentsOnly and AllDocuments.!"
  }
  validation {
    condition     = var.elasticsearch_configuration.vpc_config_role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.elasticsearch_configuration.vpc_config_role_arn)) : true
    error_message = "Error! Please provide  vpc_config_role_arn in form of arn:aws:iam::xxxxxx !"
  }
  validation {
    condition     = alltrue([var.elasticsearch_configuration.retry_duration >= 0 && var.elasticsearch_configuration.retry_duration <= 7200])
    error_message = "Error! retry_duration valid values are between 0 and 7200 "
  }
  validation {
    condition     = var.elasticsearch_configuration.role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.elasticsearch_configuration.role_arn)) : true
    error_message = "Error! Please provide role arn in form of arn:aws:iam::xxxxxx !"
  }
}

#variables for splunk_configuration 
variable "splunk_configuration" {
  description = <<-DOC
   hec_endpoint :
    The HTTP Event Collector (HEC) endpoint to which Kinesis Firehose sends your data.
   hec_token  :
    The GUID that you obtain from your Splunk cluster when you create a new HEC endpoint.
   hec_acknowledgment_timeout :
    The amount of time, in seconds between 180 and 600, that Kinesis Firehose waits to receive an acknowledgment from Splunk after it sends it data.
   hec_endpoint_type : 
    The HEC endpoint type. Valid values are Raw or Event. The default value is Raw.
   s3_backup_mode :
    Defines how documents should be delivered to Amazon S3. Valid values are FailedEventsOnly and AllEvents. Default value is FailedEventsOnly.
   retry_duration : 
    Total amount of seconds Firehose spends on retries. Valid values between 0 and 7200. Default is 300.
   log_group_name : 
    The CloudWatch group name for logging. This value is required if enabled is true.
   log_stream_name :
    The CloudWatch log stream name for logging. This value is required if enabled is true.
   processing_configuration : 
    The data processing configuration
   processing_configuration_enabled : 
    Enables or disables data processing.  
   processors :   
     Array of data processors.      
   DOC
  type = object({
    hec_endpoint               = string
    hec_token                  = string
    hec_acknowledgment_timeout = number
    hec_endpoint_type          = string
    s3_backup_mode             = string
    retry_duration             = number
    log_group_name             = string
    log_stream_name            = string
    processing_configuration = object({
      enabled    = bool
      processors = list(any)
    })
    s3_configuration = object({
      role_arn            = string
      bucket_arn          = string
      kms_key_arn         = string
      prefix              = string
      buffer_size         = number
      buffer_interval     = number
      compression_format  = string
      error_output_prefix = string
      log_group_name      = string
      log_stream_name     = string
    })
  })
  default = {
    hec_endpoint               = null
    hec_token                  = null
    hec_acknowledgment_timeout = 180
    hec_endpoint_type          = "Raw"
    s3_backup_mode             = "FailedEventsOnly"
    retry_duration             = 300
    log_group_name             = null
    log_stream_name            = null
    processing_configuration = {
      enabled    = false
      processors = []
    }
    s3_configuration = {
      role_arn            = null
      bucket_arn          = null
      kms_key_arn         = null
      prefix              = null
      buffer_size         = 5
      buffer_interval     = 300
      compression_format  = "UNCOMPRESSED"
      error_output_prefix = null
      log_group_name      = null
      log_stream_name     = null
    }
  }
  validation {
    condition     = var.splunk_configuration.hec_endpoint != null && var.splunk_configuration.log_group_name == null && var.splunk_configuration.log_stream_name == null ? false : true
    error_message = "Error! Log group name and log stream name are required!"
  }
  validation {
    condition     = var.splunk_configuration.hec_endpoint != null ? length(var.splunk_configuration.hec_endpoint) >= 0 && length(var.splunk_configuration.hec_endpoint) <= 2048 : true
    error_message = "Error! Please provide valid hec_endpoint - minimum length 0 and maximum length 2048!"
  }
  validation {
    condition     = var.splunk_configuration.hec_token != null ? length(var.splunk_configuration.hec_token) >= 0 && length(var.splunk_configuration.hec_endpoint) <= 2048 : true
    error_message = "Error! Please provide  hec_token - minimum length 0 and maximum length 2048!"
  }
  validation {
    condition     = alltrue([var.splunk_configuration.hec_acknowledgment_timeout >= 180 && var.splunk_configuration.hec_acknowledgment_timeout <= 600])
    error_message = "Error!hec_acknowledgment_timeout,the amount of time, in seconds between 180 and 600!"
  }
  validation {
    condition     = contains(["Raw", "Event"], var.splunk_configuration.hec_endpoint_type)
    error_message = "Error! hec_endpoint_type, valid values are Raw or Event!"
  }
  validation {
    condition     = contains(["FailedEventsOnly", "AllEvents"], var.splunk_configuration.s3_backup_mode)
    error_message = "Error! splunk_s3_backup_mode, valid values are  FailedEventsOnly and AllEvents!"
  }
  validation {
    condition     = alltrue([var.splunk_configuration.retry_duration >= 0 && var.splunk_configuration.retry_duration <= 7200])
    error_message = "Error! retry_duration valid values are between 0 and 7200!"
  }
}

#variables for http_endpoint_configuration
variable "http_endpoint_configuration" {
  description = <<-DOC
   url :
    The HTTP endpoint URL to which Kinesis Firehose sends your data.
   role_arn :
    Kinesis Data Firehose uses this IAM role for all the permissions that the delivery stream needs. The pattern needs to be arn:.*.
   name : 
    The HTTP endpoint name.
   access_key : 
    The access key required for Kinesis Firehose to authenticate with the HTTP endpoint selected as the destination.
   buffering_size : 
    Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5."
   buffering_interval : 
    Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300 (5 minutes).
   content_encoding : 
    Kinesis Data Firehose uses the content encoding to compress the body of a request before sending the request to the destination. Valid values are NONE and GZIP. Default value is NONE.
   s3_backup_mode : 
    Defines how documents should be delivered to Amazon S3. Valid values are FailedDataOnly and AllData. Default value is FailedDataOnly.
   common_attributes :   
    Describes the metadata sent to the HTTP endpoint destination.
   retry_duration : 
    Total amount of seconds Firehose spends on retries. Valid values between 0 and 7200. Default is 300.
   log_group_name : 
    The CloudWatch group name for logging. This value is required if enabled is true.
   log_stream_name :
    The CloudWatch log stream name for logging. This value is required if enabled is true.   
   processing_configuration : 
    The data processing configuration
   processing_configuration_enabled : 
    Enables or disables data processing.    
   processors :   
     Array of data processors.    
  DOC
  type = object({
    url                = string
    role_arn           = string
    name               = string
    access_key         = string
    buffering_size     = number
    buffering_interval = number
    s3_backup_mode     = string
    content_encoding   = string
    common_attributes  = map(string)
    retry_duration     = number
    log_group_name     = string
    log_stream_name    = string
    processing_configuration = object({
      enabled    = bool
      processors = list(any)
    })
    s3_configuration = object({
      role_arn            = string
      bucket_arn          = string
      kms_key_arn         = string
      prefix              = string
      buffer_size         = number
      buffer_interval     = number
      compression_format  = string
      error_output_prefix = string
      log_group_name      = string
      log_stream_name     = string
    })
  })
  default = {
    url                = null
    role_arn           = null
    name               = null
    access_key         = null
    buffering_size     = 5
    buffering_interval = 300
    s3_backup_mode     = "FailedDataOnly"
    content_encoding   = "NONE"
    common_attributes  = {}
    retry_duration     = 3600
    log_group_name     = null
    log_stream_name    = null
    processing_configuration = {
      enabled    = false
      processors = []
    }
    s3_configuration = {
      role_arn            = null
      bucket_arn          = null
      kms_key_arn         = null
      prefix              = null
      buffer_size         = 5
      buffer_interval     = 300
      compression_format  = "UNCOMPRESSED"
      error_output_prefix = null
      log_group_name      = null
      log_stream_name     = null
    }
  }
  validation {
    condition     = var.http_endpoint_configuration.role_arn != null && var.http_endpoint_configuration.log_group_name == null && var.http_endpoint_configuration.log_stream_name == null ? false : true
    error_message = "Error! Log group name and log stream name are required!"
  }
  validation {
    condition     = var.http_endpoint_configuration.url != null ? can(regex("^https://\\w+", var.http_endpoint_configuration.url)) && length(var.http_endpoint_configuration.url) >= 1 && length(var.http_endpoint_configuration.url) <= 1000 : true
    error_message = "Error! Please provide url in form of https://xxxx and length minimum 1 and maximum 1000!"
  }
  validation {
    condition     = var.http_endpoint_configuration.role_arn != null ? can(regex("^arn:aws:iam::\\w+", var.http_endpoint_configuration.role_arn)) : true
    error_message = "Error! Please provide role arn in form of arn:aws:iam::xxxxxx !"
  }
  validation {
    condition     = var.http_endpoint_configuration.name != null ? length(var.http_endpoint_configuration.name) >= 1 && length(var.http_endpoint_configuration.name) <= 256 : true
    error_message = "Error! Please provide name - minimum 1 and maximum of 256!"
  }
  validation {
    condition     = var.http_endpoint_configuration.access_key != null ? length(var.http_endpoint_configuration.access_key) >= 0 && length(var.http_endpoint_configuration.access_key) <= 4096 : true
    error_message = "Error! Please provide access_key - minimum 0 and maximum of 4096!"
  }
  validation {
    condition     = contains(["NONE", "GZIP"], var.http_endpoint_configuration.content_encoding)
    error_message = "Error! content_encoding, valid values are NONE and GZIP!"
  }
  validation {
    condition     = contains(["FailedDataOnly", "AllData"], var.http_endpoint_configuration.s3_backup_mode)
    error_message = "Error! http_s3_backup_mode, valid values are FailedDataOnly and AllData!"
  }
  validation {
    condition     = alltrue([var.http_endpoint_configuration.retry_duration >= 0 && var.http_endpoint_configuration.retry_duration <= 7200])
    error_message = "Error! retry_duration valid values are between 0 and 7200 "
  }
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"

  tags = var.tags
}


variable "enable_server_side_encryption" {
  description = "Flag to enable server side encryption"
  type        = bool
  default     = true
}