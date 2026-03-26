/*
 * # AWS DynamoDb Global Table module for V1 (version 2017.11.29).
 * To instead manage DynamoDB Global Tables V2 (version 2019.11.21), use the 'dynamodb_table' module - replica configuration block.
 * Terraform module which creates SAF2.0 Dynamodb Global tables v1 in AWS in regions: "us-west-2" and "us-east-1" in AWS.
 * Customer Manged CMK's are not supported in global tables V1.
*/

#  Filename    : aws/modules/dynamodb/modules/dynamodb_global_table/main.tf
#  Date        : 30 March 2022
#  Author      : TCS
#  Description : dynamodb with global table
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




# For old versions of terraform, an empty table is created in each region, then a global table is created to tie them together.
# For new versions of terraform ,a table is created in a region, then add regions which creates new tables in the target region.

resource "aws_dynamodb_global_table" "dynamodb_global_table" {

  name = var.table_name

  # Defines the primary region of the dynamodb table.
  replica {
    region_name = var.primary_aws_region
  }

  # Defines the global replica region for the dynamodb- global replica.
  replica {
    region_name = var.global_replica_region_name
  }

}
