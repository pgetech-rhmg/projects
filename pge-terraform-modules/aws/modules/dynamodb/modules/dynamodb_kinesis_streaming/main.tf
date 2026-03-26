/*
 * # AWS DynamoDb Kinesis Streaming destination module
 * Terraform module which enables Kinesis streaming destination for data replication of SAF 2.0 Dynamodb table in AWS.
*/

#
#  Filename    : aws/modules/dynamodb/modules/dynamodb_table_kinesis_streaming/main.tf
#  Date        : 31 March 2022
#  Author      : TCS
#  Description : dynamodb with kinesis streaming
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


# Module      : dynamodb with kinesis streaming destination
# Description : This terraform module creates a dynamodb with kinesis streaming destination.

resource "aws_dynamodb_kinesis_streaming_destination" "dynamodb_kinesis_streaming_destination" {
  stream_arn = var.stream_arn
  table_name = var.table_name
}
