account_num = "056672152820"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "DatabaseAdmin"
aws_service = ["firehose.amazonaws.com"]

AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                          #Order must be between 7 and 9 digits
optional_tags = {
  managed_by = "terraform"
}

#common vriable for name 
name = "example"

#firehose
server_side_encryption_key_arn = null
enable_server_side_encryption  = true
s3_backup_mode                 = "Disabled"
prefix                         = null
buffer_size                    = 64
buffer_interval                = 300
compression_format             = "UNCOMPRESSED"
error_output_prefix            = null
log_stream_name                = "extended_s3_log"
#s3_backup configuration
s3_backup_prefix              = null
s3_backup_buffer_size         = 64
s3_backup_buffer_interval     = 300
s3_backup_compression_format  = "UNCOMPRESSED"
s3_backup_error_output_prefix = null
s3_backup_log_stream_name     = "s3_backup_log"
#data format conversion
data_format_conversion_enabled                              = false
deserializer                                                = "open_x_json_ser_de"
hive_json_ser_de_timestamp_formats                          = []
open_x_json_ser_de_case_insensitive                         = true
open_x_json_ser_de_column_to_json_key_mappings              = null
open_x_json_ser_de_convert_dots_in_json_keys_to_underscores = false
serializer                                                  = "orc_ser_de"
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
schema_configuration_version_id                             = "LATEST"
#dynamic_partitioning
dynamic_partitioning_enabled                       = false
dynamic_partitioning_retry_duration                = 300
processing_configuration_enabled                   = true
processing_configuration_processors_type           = "Lambda"
processing_configuration_processors_parameter_name = "LambdaArn"

#iam policy
path = "/"

#kinesis datastream
stream_mode = {
  shard_count         = 2
  stream_mode_details = "PROVISIONED"
}
shard_level_metrics = ["WriteProvisionedThroughputExceeded", "ReadProvisionedThroughputExceeded", "IteratorAgeMilliseconds"]

#glue database and table
create_table_default_permission = [{
  permissions = ["SELECT"]
  principal = [{
    data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
  }]
}]

table_type = "EXTERNAL_TABLE"

parameters = {
  objectCount       = "1",
  averageRecordSize = "40",
  compressionType   = "none",
  classification    = "csv",
  columnsOrdered    = "true",
  areColumnsQuoted  = "false",
}

partition_keys = [{
  name = "rating"
  type = "string"
}]

storage_descriptor = [{
  location                  = "s3://test-iac-s3-bucket/read/"
  input_format              = "org.apache.hadoop.mapred.TextInputFormat"
  output_format             = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
  compressed                = false
  stored_as_sub_directories = false

  parameters = {
    objectCount       = "1",
    averageRecordSize = "40",
    compressionType   = "none",
    classification    = "csv",
    columnsOrdered    = "true",
    areColumnsQuoted  = "false",
  }

  columns = [{
    name = "rank"
    type = "bigint"
    },
    {
      name = "movie_title"
      type = "string"
    },
    {
      name = "year",
      type = "bigint",
    },
    {
      name = "rating",
      type = "double",
  }]

  ser_de_info = [{
    name             = "test",
    serializationLib = "org.apache.hadoop.hive.serde2.OpenCSVSerde",
    parameters = {
      quoteChar     = "test",
      separatorChar = ","
    }
  }]
}]

#parameter store names
vpc_id_name     = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"
#Lambda
function_name              = "lambda-local-tf-test-oxdi-"
description                = "testing aws lambda"
runtime                    = "python3.9"
handler                    = "lambda_function.lambda_handler"
local_zip_source_directory = "lambda_source_code"
#security_group
lambda_sg_name = "lambda_sg_oxdi_test"

lambda_cidr_ingress_rules = [{
  from             = 80,
  to               = 80,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
  },
  {
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
}]

lambda_cidr_egress_rules = [{
  from             = 0,
  to               = 0,
  protocol         = "-1",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
}]
#Iam_role 
iam_name        = "lambda_policy_oxdi_test"
iam_aws_service = ["lambda.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole", "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AmazonKinesisFullAccess", "arn:aws:iam::aws:policy/AmazonSQSFullAccess"]