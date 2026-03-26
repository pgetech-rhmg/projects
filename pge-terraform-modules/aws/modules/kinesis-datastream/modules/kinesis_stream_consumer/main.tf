/*
*#AWS Kinesis data stream module
*Terraform module which creates kinesis stream consumer
*/
#Filename     : aws/modules/kinesis-datastream/modules/kinesis_stream_consumer/main.tf 
#database     : 02 Sep 2022
#Author       : TCS
#Description  : Terraform module for creation of kinesis stream consumer 
#

terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#Module : kinesis data stream consumer
#Description : This terraform module creates kinesis stream consumer



resource "aws_kinesis_stream_consumer" "kinesis_stream_consumer" {
  name       = var.name
  stream_arn = var.stream_arn
}