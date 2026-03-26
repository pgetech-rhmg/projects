/*
 * # AWS Elasticache-redis module
 * Terraform module which creates SAF2.0 Elasticache-redis cluster global replication group in AWS.
 * KNOWN ERROR IN CREATING SECONDARY CLUSTER FOR THE GLOBAL REPLICATION GROUP
 * Error while updating the secondary cluster for the global replication group.
 * Error Message: "InvalidParameterCombination: Cannot use the given parameters when creating new replication group in an existing global replication group."
 * Reference Link: https://github.com/hashicorp/terraform-provider-aws/issues/24854
*/

#  Filename    : aws/modules/Elasticache-redis/modules/elasticache-redis-global-replication-group/main.tf
#  Date        : 21 April 2022
#  Author      : TCS
#  Description : Elasticache-redis clusters
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

locals {

  # The parameter group family coincides with the cluster's engine version. The below line fetches the parameter_group "family" from the "redis_engine_version".

}

resource "aws_elasticache_global_replication_group" "global" {
  global_replication_group_id_suffix   = var.global_suffix
  primary_replication_group_id         = var.primary_replication_group_id
  global_replication_group_description = "Global replication group-${var.cluster_id}"
  engine_version                       = var.redis_engine_version
}

# The secondary cluster for the global replication group is not updated as there is a known error when updating the secondary cluster.
# Error Message: " InvalidParameterCombination: Cannot use the given parameters when creating new replication group in an existing global replication group."
# https://github.com/hashicorp/terraform-provider-aws/issues/24854
