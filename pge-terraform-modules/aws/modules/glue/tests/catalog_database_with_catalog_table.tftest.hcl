run "catalog_database_with_catalog_table" {
  command = apply

  module {
    source = "./examples/catalog_database_with_catalog_table"
  }
}

variables {
  account_num = "056672152820"
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  name        = "testdb_03"
  description = "catalog database - Managed by Terraform"
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
  glue_partition_values     = ["4"]
  location                  = "s3://test-iac-s3-bucket/read/"
  input_format              = "org.apache.hadoop.mapred.TextInputFormat"
  output_format             = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
  compressed                = false
  stored_as_sub_directories = false
  partition_parameters = {
    objectCount       = "1",
    averageRecordSize = "40",
    compressionType   = "none",
    classification    = "csv",
    columnsOrdered    = "true",
    areColumnsQuoted  = "false",
  }
  columns_name_1               = "rank"
  columns_type_1               = "bigint"
  columns_name_2               = "movie_title"
  columns_type_2               = "string"
  columns_name_3               = "year"
  columns_type_3               = "bigint"
  columns_name_4               = "rating"
  columns_type_4               = "double"
  ser_de_info_name             = "test2"
  ser_de_info_serializationLib = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
  ser_de_info_parameters = {
    quoteChar     = "test",
    separatorChar = ","
  }
  partition_index_name = "test1"
  partition_index_keys = ["rating"]
  function_name        = "my_func"
  class_name           = "class"
  owner_name           = "owner"
  owner_type           = "GROUP"
  resource_type        = "ARCHIVE"
  uri                  = "uri"
}
