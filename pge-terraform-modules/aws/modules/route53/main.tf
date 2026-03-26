/*
 * # AWS ROUTE 53 module
 * Terraform module which creates SAF2.0 Route 53 in AWS
*/

#
#  Filename    : aws/modules/Route_53/modules/record/main.tf
#  Date        : 08 july 2022
#  Author      : TCS
#  Description : Route 53 terraform module to create multiple records.
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

# Module      : record
# Description : This terraform module creates a record.

#This resource is able to create multiple records.
resource "aws_route53_record" "records" {
  # The following resource below is able to create multiple route 53 records. The resource will be disabled by default,
  # and it wil be enabled when the user gives value to the resource. The user can give the value to the variable var.records.
  for_each = { for value in var.records : value.name => value }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  #The argument ttl is required for non-alias records. If alias block is provided by the user, then ttl value provided by the user will not be used.
  #The argument records is required for non-alias records. If alias block is provided by the user, then records value provided by the user will not be used.
  ttl     = lookup(each.value, "ttl", null)
  records = lookup(each.value, "records", null)

  set_identifier  = lookup(each.value, "set_identifier", null)
  health_check_id = lookup(each.value, "health_check_id", null)

  #The alias block is optional. So this block will be disabled by default until the user provides value to the alias block.
  dynamic "alias" {
    for_each = lookup(each.value, "alias", {})
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  #The failover_routing_policy block is optional. So this block will be disabled by default until the user provides value to the failover_routing_policy block.
  #failover_routing_policy block checks with all other policies and it will throw an error if there is any other routing policy.
  dynamic "failover_routing_policy" {
    for_each = lookup(each.value, "failover_routing_policy", {})
    content {
      type = failover_routing_policy.value.type
    }
  }

  #The geolocation_routing_policy block is optional. So this block will be disabled by default until the user provides value to the geolocation_routing_policy block.
  #geolocation_routing_policy block checks with all other policies and it will throw an error if there is any other routing policy.
  dynamic "geolocation_routing_policy" {
    for_each = lookup(each.value, "geolocation_routing_policy", {})
    content {
      #Use either continent or country argument for geolocation routing policy.
      continent   = lookup(geolocation_routing_policy.value, "country", null) == null ? geolocation_routing_policy.value.continent : null
      country     = lookup(geolocation_routing_policy.value, "continent", null) == null ? geolocation_routing_policy.value.country : null
      subdivision = lookup(geolocation_routing_policy.value, "country", null) == "US" ? geolocation_routing_policy.value.subdivision : null
    }
  }

  #The latency_routing_policy block is optional. So this block will be disabled by default until the user provides value to the latency_routing_policy block.
  #latency_routing_policy block checks with all other policies and it will throw an error if there is any other routing policy.
  dynamic "latency_routing_policy" {
    for_each = lookup(each.value, "latency_routing_policy", {})
    content {
      region = latency_routing_policy.value.region
    }
  }

  #The weighted_routing_policy block is optional. So this block will be disabled by default until the user provides value to the weighted_routing_policy block.
  #weighted_routing_policy block checks with all other policies and it will throw an error if there is any other routing policy.
  dynamic "weighted_routing_policy" {
    for_each = lookup(each.value, "weighted_routing_policy", {})
    content {
      weight = weighted_routing_policy.value.weight
    }
  }
  #multivalue_answer_routing_policy argument checks with all other policies and it will throw an error if there is any other routing policy.
  multivalue_answer_routing_policy = lookup(each.value, "multivalue_answer_routing_policy", null)
  allow_overwrite                  = false
}