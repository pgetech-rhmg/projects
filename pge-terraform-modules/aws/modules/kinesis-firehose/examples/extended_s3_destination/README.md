<!-- BEGIN_TF_DOCS -->
# AWS Kinesis firehose  User module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.4.3 |
| <a name="requirement_template"></a> [template](#requirement\_template) | 2.2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.4.3 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_lambda_iam_role"></a> [aws\_lambda\_iam\_role](#module\_aws\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_catalog_database"></a> [catalog\_database](#module\_catalog\_database) | app.terraform.io/pgetech/glue/aws//modules/catalog_database | 0.1.1 |
| <a name="module_catalog_table"></a> [catalog\_table](#module\_catalog\_table) | app.terraform.io/pgetech/glue/aws//modules/catalog_table | 0.1.1 |
| <a name="module_extended_s3_firehose"></a> [extended\_s3\_firehose](#module\_extended\_s3\_firehose) | ../../ | n/a |
| <a name="module_firehose_aws_iam_role"></a> [firehose\_aws\_iam\_role](#module\_firehose\_aws\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_firehose_iam_policy"></a> [firehose\_iam\_policy](#module\_firehose\_iam\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_kinesis_stream"></a> [kinesis\_stream](#module\_kinesis\_stream) | app.terraform.io/pgetech/kinesis-datastream/aws | 0.1.1 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.3 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_security_group_lambda"></a> [security\_group\_lambda](#module\_security\_group\_lambda) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_stream.log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [template_file.s3_custom_bucket_policy](https://registry.terraform.io/providers/hashicorp/template/2.2.0/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | A list of AWS services allowed to assume this role.  Required if the trusted\_aws\_principals variable is not provided. | `list(string)` | `[]` | no |
| <a name="input_buffer_interval"></a> [buffer\_interval](#input\_buffer\_interval) | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300. | `number` | n/a | yes |
| <a name="input_buffer_size"></a> [buffer\_size](#input\_buffer\_size) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher. | `number` | n/a | yes |
| <a name="input_compression_format"></a> [compression\_format](#input\_compression\_format) | The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP\_SNAPPY. | `string` | n/a | yes |
| <a name="input_create_table_default_permission"></a> [create\_table\_default\_permission](#input\_create\_table\_default\_permission) | Creates a set of default permissions on the table for principals. | `any` | n/a | yes |
| <a name="input_data_format_conversion_enabled"></a> [data\_format\_conversion\_enabled](#input\_data\_format\_conversion\_enabled) | Defaults to true. Set it to false if you want to disable format conversion while preserving the configuration details. | `bool` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of what your Lambda Function does | `string` | n/a | yes |
| <a name="input_deserializer"></a> [deserializer](#input\_deserializer) | Provide value either 'hive\_json\_ser\_de' or 'open\_x\_json\_ser\_de' to select respective block to execute. | `string` | n/a | yes |
| <a name="input_dynamic_partitioning_enabled"></a> [dynamic\_partitioning\_enabled](#input\_dynamic\_partitioning\_enabled) | Enables or disables dynamic partitioning. Defaults to false. | `bool` | n/a | yes |
| <a name="input_dynamic_partitioning_retry_duration"></a> [dynamic\_partitioning\_retry\_duration](#input\_dynamic\_partitioning\_retry\_duration) | Total amount of seconds Firehose spends on retries. Valid values between 0 and 7200. Default is 300. | `number` | n/a | yes |
| <a name="input_enable_server_side_encryption"></a> [enable\_server\_side\_encryption](#input\_enable\_server\_side\_encryption) | Flag to enable server side encryption | `bool` | n/a | yes |
| <a name="input_error_output_prefix"></a> [error\_output\_prefix](#input\_error\_output\_prefix) | Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects. | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Unique name for your Lambda Function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_hive_json_ser_de_timestamp_formats"></a> [hive\_json\_ser\_de\_timestamp\_formats](#input\_hive\_json\_ser\_de\_timestamp\_formats) | A list of how you want Kinesis Data Firehose to parse the date and time stamps that may be present in your input data JSON. To specify these format strings, follow the pattern syntax of JodaTime's DateTimeFormat format strings. For more information, see Class DateTimeFormat. You can also use the special value millis to parse time stamps in epoch milliseconds. If you don't specify a format, Kinesis Data Firehose uses java.sql.Timestamp::valueOf by default. | `list(string)` | n/a | yes |
| <a name="input_iam_aws_service"></a> [iam\_aws\_service](#input\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_iam_name"></a> [iam\_name](#input\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | KMS role to assume | `string` | n/a | yes |
| <a name="input_lambda_cidr_egress_rules"></a> [lambda\_cidr\_egress\_rules](#input\_lambda\_cidr\_egress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_lambda_cidr_ingress_rules"></a> [lambda\_cidr\_ingress\_rules](#input\_lambda\_cidr\_ingress\_rules) | variables for security\_group | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_lambda_sg_name"></a> [lambda\_sg\_name](#input\_lambda\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_local_zip_source_directory"></a> [local\_zip\_source\_directory](#input\_local\_zip\_source\_directory) | Package entire contents of this directory into the archive | `string` | n/a | yes |
| <a name="input_log_stream_name"></a> [log\_stream\_name](#input\_log\_stream\_name) | The CloudWatch log stream name for logging. This value is required if enabled is true. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A common name for resources. | `string` | n/a | yes |
| <a name="input_open_x_json_ser_de_case_insensitive"></a> [open\_x\_json\_ser\_de\_case\_insensitive](#input\_open\_x\_json\_ser\_de\_case\_insensitive) | When set to true, which is the default, Kinesis Data Firehose converts JSON keys to lowercase before deserializing them. | `bool` | n/a | yes |
| <a name="input_open_x_json_ser_de_column_to_json_key_mappings"></a> [open\_x\_json\_ser\_de\_column\_to\_json\_key\_mappings](#input\_open\_x\_json\_ser\_de\_column\_to\_json\_key\_mappings) | A map of column names to JSON keys that aren't identical to the column names. This is useful when the JSON contains keys that are Hive keywords. For example, timestamp is a Hive keyword. If you have a JSON key named timestamp, set this parameter to { ts = 'timestamp' } to map this key to a column named ts. | `map(string)` | n/a | yes |
| <a name="input_open_x_json_ser_de_convert_dots_in_json_keys_to_underscores"></a> [open\_x\_json\_ser\_de\_convert\_dots\_in\_json\_keys\_to\_underscores](#input\_open\_x\_json\_ser\_de\_convert\_dots\_in\_json\_keys\_to\_underscores) | When set to true, specifies that the names of the keys include dots and that you want Kinesis Data Firehose to replace them with underscores. This is useful because Apache Hive does not allow dots in column names. For example, if the JSON contains a key whose name is 'a.b', you can define the column name to be 'a\_b' when using this option. Defaults to false. | `bool` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_orc_ser_de_block_size_bytes"></a> [orc\_ser\_de\_block\_size\_bytes](#input\_orc\_ser\_de\_block\_size\_bytes) | The Hadoop Distributed File System (HDFS) block size. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 256 MiB and the minimum is 64 MiB. Kinesis Data Firehose uses this value for padding calculations. | `number` | n/a | yes |
| <a name="input_orc_ser_de_bloom_filter_columns"></a> [orc\_ser\_de\_bloom\_filter\_columns](#input\_orc\_ser\_de\_bloom\_filter\_columns) | A list of column names for which you want Kinesis Data Firehose to create bloom filters. | `list(string)` | n/a | yes |
| <a name="input_orc_ser_de_bloom_filter_false_positive_probability"></a> [orc\_ser\_de\_bloom\_filter\_false\_positive\_probability](#input\_orc\_ser\_de\_bloom\_filter\_false\_positive\_probability) | The Bloom filter false positive probability (FPP). The lower the FPP, the bigger the Bloom filter. The default value is 0.05, the minimum is 0, and the maximum is 1. | `number` | n/a | yes |
| <a name="input_orc_ser_de_compression"></a> [orc\_ser\_de\_compression](#input\_orc\_ser\_de\_compression) | The compression code to use over data blocks. The possible values are UNCOMPRESSED, SNAPPY, and GZIP, with the default being SNAPPY. Use SNAPPY for higher decompression speed. Use GZIP if the compression ratio is more important than speed. | `string` | n/a | yes |
| <a name="input_orc_ser_de_dictionary_key_threshold"></a> [orc\_ser\_de\_dictionary\_key\_threshold](#input\_orc\_ser\_de\_dictionary\_key\_threshold) | A float that represents the fraction of the total number of non-null rows. To turn off dictionary encoding, set this fraction to a number that is less than the number of distinct keys in a dictionary. To always use dictionary encoding, set this threshold to 1. | `number` | n/a | yes |
| <a name="input_orc_ser_de_enable_padding"></a> [orc\_ser\_de\_enable\_padding](#input\_orc\_ser\_de\_enable\_padding) | Set this to true to indicate that you want stripes to be padded to the HDFS block boundaries. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is false. | `bool` | n/a | yes |
| <a name="input_orc_ser_de_format_version"></a> [orc\_ser\_de\_format\_version](#input\_orc\_ser\_de\_format\_version) | The version of the file to write. The possible values are V0\_11 and V0\_12. The default is V0\_12. | `string` | n/a | yes |
| <a name="input_orc_ser_de_padding_tolerance"></a> [orc\_ser\_de\_padding\_tolerance](#input\_orc\_ser\_de\_padding\_tolerance) | A float between 0 and 1 that defines the tolerance for block padding as a decimal fraction of stripe size. The default value is 0.05, which means 5 percent of stripe size. For the default values of 64 MiB ORC stripes and 256 MiB HDFS blocks, the default block padding tolerance of 5 percent reserves a maximum of 3.2 MiB for padding within the 256 MiB block. In such a case, if the available size within the block is more than 3.2 MiB, a new, smaller stripe is inserted to fit within that space. This ensures that no stripe crosses block boundaries and causes remote reads within a node-local task. Kinesis Data Firehose ignores this parameter when enable\_padding is false. | `number` | n/a | yes |
| <a name="input_orc_ser_de_row_index_stride"></a> [orc\_ser\_de\_row\_index\_stride](#input\_orc\_ser\_de\_row\_index\_stride) | The number of rows between index entries. The default is 10000 and the minimum is 1000. | `number` | n/a | yes |
| <a name="input_orc_ser_de_stripe_size_bytes"></a> [orc\_ser\_de\_stripe\_size\_bytes](#input\_orc\_ser\_de\_stripe\_size\_bytes) | The number of bytes in each stripe. The default is 64 MiB and the minimum is 8 MiB. | `number` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Properties associated with this table, as a list of key-value pairs | `map(string)` | n/a | yes |
| <a name="input_parquet_ser_de_block_size_bytes"></a> [parquet\_ser\_de\_block\_size\_bytes](#input\_parquet\_ser\_de\_block\_size\_bytes) | The Hadoop Distributed File System (HDFS) block size. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 256 MiB and the minimum is 64 MiB. Kinesis Data Firehose uses this value for padding calculations. | `number` | n/a | yes |
| <a name="input_parquet_ser_de_compression"></a> [parquet\_ser\_de\_compression](#input\_parquet\_ser\_de\_compression) | The compression code to use over data blocks. The possible values are UNCOMPRESSED, SNAPPY, and GZIP, with the default being SNAPPY. Use SNAPPY for higher decompression speed. Use GZIP if the compression ratio is more important than speed. | `string` | n/a | yes |
| <a name="input_parquet_ser_de_enable_dictionary_compression"></a> [parquet\_ser\_de\_enable\_dictionary\_compression](#input\_parquet\_ser\_de\_enable\_dictionary\_compression) | Indicates whether to enable dictionary compression. | `bool` | n/a | yes |
| <a name="input_parquet_ser_de_max_padding_bytes"></a> [parquet\_ser\_de\_max\_padding\_bytes](#input\_parquet\_ser\_de\_max\_padding\_bytes) | The maximum amount of padding to apply. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The default is 0. | `number` | n/a | yes |
| <a name="input_parquet_ser_de_page_size_bytes"></a> [parquet\_ser\_de\_page\_size\_bytes](#input\_parquet\_ser\_de\_page\_size\_bytes) | The Parquet page size. Column chunks are divided into pages. A page is conceptually an indivisible unit (in terms of compression and encoding). The minimum value is 64 KiB and the default is 1 MiB. | `number` | n/a | yes |
| <a name="input_parquet_ser_de_writer_version"></a> [parquet\_ser\_de\_writer\_version](#input\_parquet\_ser\_de\_writer\_version) | Indicates the version of row format to output. The possible values are V1 and V2. The default is V1. | `string` | n/a | yes |
| <a name="input_partition_keys"></a> [partition\_keys](#input\_partition\_keys) | Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys | `list(map(string))` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | The path of the policy in IAM | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket | `string` | n/a | yes |
| <a name="input_processing_configuration_enabled"></a> [processing\_configuration\_enabled](#input\_processing\_configuration\_enabled) | Enables or disables data processing. | `bool` | n/a | yes |
| <a name="input_processing_configuration_processors_parameter_name"></a> [processing\_configuration\_processors\_parameter\_name](#input\_processing\_configuration\_processors\_parameter\_name) | Parameter name. Valid Values: LambdaArn, NumberOfRetries, MetadataExtractionQuery, JsonParsingEngine, RoleArn, BufferSizeInMBs, BufferIntervalInSeconds, SubRecordType, Delimiter. Validation is done against AWS SDK constants; so that values not explicitly listed may also work. | `string` | n/a | yes |
| <a name="input_processing_configuration_processors_type"></a> [processing\_configuration\_processors\_type](#input\_processing\_configuration\_processors\_type) | The type of processor. Valid Values: RecordDeAggregation, Lambda, MetadataExtraction, AppendDelimiterToRecord. Validation is done against AWS SDK constants; so that values not explicitly listed may also work. | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_s3_backup_buffer_interval"></a> [s3\_backup\_buffer\_interval](#input\_s3\_backup\_buffer\_interval) | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300. | `number` | n/a | yes |
| <a name="input_s3_backup_buffer_size"></a> [s3\_backup\_buffer\_size](#input\_s3\_backup\_buffer\_size) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher. | `number` | n/a | yes |
| <a name="input_s3_backup_compression_format"></a> [s3\_backup\_compression\_format](#input\_s3\_backup\_compression\_format) | The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP\_SNAPPY. | `string` | n/a | yes |
| <a name="input_s3_backup_error_output_prefix"></a> [s3\_backup\_error\_output\_prefix](#input\_s3\_backup\_error\_output\_prefix) | Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects. | `string` | n/a | yes |
| <a name="input_s3_backup_log_stream_name"></a> [s3\_backup\_log\_stream\_name](#input\_s3\_backup\_log\_stream\_name) | The CloudWatch log stream name for logging. This value is required if enabled is true. | `string` | n/a | yes |
| <a name="input_s3_backup_mode"></a> [s3\_backup\_mode](#input\_s3\_backup\_mode) | The Amazon S3 backup mode. Valid values are Disabled and Enabled. Default value is Disabled. | `string` | n/a | yes |
| <a name="input_s3_backup_prefix"></a> [s3\_backup\_prefix](#input\_s3\_backup\_prefix) | The 'YYYY/MM/DD/HH' time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket | `string` | n/a | yes |
| <a name="input_schema_configuration_version_id"></a> [schema\_configuration\_version\_id](#input\_schema\_configuration\_version\_id) | Specifies the table version for the output data schema. Defaults to LATEST. | `string` | n/a | yes |
| <a name="input_serializer"></a> [serializer](#input\_serializer) | Provide value either 'orc\_ser\_de' or ;parquet\_ser\_de' to select respective block to execute. | `string` | n/a | yes |
| <a name="input_server_side_encryption_key_arn"></a> [server\_side\_encryption\_key\_arn](#input\_server\_side\_encryption\_key\_arn) | Amazon Resource Name (ARN) of the encryption key. Required when key\_type is CUSTOMER\_MANAGED\_CMK. | `string` | n/a | yes |
| <a name="input_shard_level_metrics"></a> [shard\_level\_metrics](#input\_shard\_level\_metrics) | A list of shard-level CloudWatch metrics which can be enabled for the stream. See Monitoring with CloudWatch for more. Note that the value ALL should not be used; instead you should provide an explicit list of metrics you wish to enable. | `list(string)` | n/a | yes |
| <a name="input_storage_descriptor"></a> [storage\_descriptor](#input\_storage\_descriptor) | Configuration block for information about the physical storage of this table | `list(any)` | n/a | yes |
| <a name="input_stream_mode"></a> [stream\_mode](#input\_stream\_mode) | shard\_count:<br>    (Optional) The number of shards that the stream will use. If the stream\_mode is PROVISIONED, this field is required. Amazon has guidelines for specifying the Stream size that should be referenced when creating a Kinesis stream. See Amazon Kinesis Streams for more.<br>stream\_mode\_details:<br>    (Optional) Specifies the capacity mode of the stream. Must be either PROVISIONED or ON\_DEMAND. | <pre>object({<br>    shard_count         = number<br>    stream_mode_details = string<br>  })</pre> | n/a | yes |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1 | `string` | n/a | yes |
| <a name="input_table_type"></a> [table\_type](#input\_table\_type) | Type of this table (EXTERNAL\_TABLE, VIRTUAL\_VIEW, etc.). While optional, some Athena DDL queries such as ALTER TABLE and SHOW CREATE TABLE will fail if this argument is empty | `string` | n/a | yes |
| <a name="input_vpc_id_name"></a> [vpc\_id\_name](#input\_vpc\_id\_name) | The name given in the parameter store for the vpc id | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) specifying the Stream |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->