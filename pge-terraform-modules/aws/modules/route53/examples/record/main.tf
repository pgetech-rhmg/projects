/*
 * # AWS Route53 module Record example
*/
#
# Filename    : aws/modules/Route_53/examples/record/main.tf
# Date        : 08 july 2022
# Author      : TCS
# Description : Terraform module example for Route53 record
#

#########################################
# Create record
#########################################

#Example to create multiple records
module "records" {
  source  = "../../"
  zone_id = var.zone_id

  records = [
    {
      name    = "test1"
      type    = "A"
      ttl     = "300"
      records = ["192.0.2.1"]
    },
    {
      name    = "test2"
      type    = "CNAME"
      ttl     = "300"
      records = ["www.example.com"]
    }
  ]
}

#Example to create different types of routing_policy 
module "records_with_policy" {
  source  = "../../"
  zone_id = var.zone_id
  records = [
    {
      name            = "test3"
      type            = "A"
      ttl             = "300"
      records         = ["192.0.2.3"]
      set_identifier  = "failOver1"
      health_check_id = "6a2e73e6-b36d-42e1-ab6d-66422aaffb9e"
      failover_routing_policy = [{
        type = "PRIMARY"
      }]
    },
    {
      name           = "test4"
      type           = "CNAME"
      ttl            = "300"
      records        = ["www.example4.com"]
      set_identifier = "geoRoute"
      geolocation_routing_policy = [{
        country     = "US"
        subdivision = "NY"
      }]
    },
    {
      name           = "test5"
      type           = "A"
      ttl            = "300"
      records        = ["192.0.2.5"]
      set_identifier = "latRoute"
      latency_routing_policy = [{
        region = "us-west-2"
      }]
    },
    {
      name           = "test6"
      type           = "A"
      ttl            = "300"
      records        = ["192.0.2.6"]
      set_identifier = "weightRoute"
      weighted_routing_policy = [{
        weight = "200"
      }]
    },
    {
      name                             = "test7"
      type                             = "A"
      ttl                              = "300"
      records                          = ["192.0.2.7"]
      set_identifier                   = "multivalueRoute"
      multivalue_answer_routing_policy = true
    }
  ]
}