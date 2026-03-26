/*
AWS Redshift module
*Terraform module for Scheduled action
#Filename     : aws/modules/redshift/modules/scheduled_action/main.tf 
#Date         : 20 July 2022
#Author       : TCS
#Description  : Terraform module for Scheduled action
*/
terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

resource "aws_redshift_scheduled_action" "scheduled_action" {
  #The condition will process the variable scheduled_actions and loop over the resource if variable 'enable' is true.
  for_each = { for ki, vi in var.scheduled_actions : ki => vi if var.enable }

  iam_role    = var.iam_role
  name        = each.value.name
  description = coalesce(var.description, format("%s scheduled_action", var.name))
  start_time  = try(each.value.start_time, null)
  end_time    = try(each.value.end_time, null)
  schedule    = each.value.schedule
  target_action {
    dynamic "pause_cluster" {
      #This loop will execute only if the value of scheduled_actions is 'Pause_cluster"
      for_each = can(each.value.pause_cluster) ? [each.value.pause_cluster] : []

      content {
        cluster_identifier = var.cluster_identifier
      }
    }
    dynamic "resize_cluster" {
      #This loop will execute only if the value of scheduled_actions is 'resize_cluster"
      for_each = can(each.value.resize_cluster) ? [each.value.resize_cluster] : []

      content {
        classic            = try(resize_cluster.value.classic, null)
        cluster_identifier = var.cluster_identifier
        cluster_type       = try(resize_cluster.value.cluster_type, null)
        node_type          = try(resize_cluster.value.node_type, null)
        number_of_nodes    = try(resize_cluster.value.number_of_nodes, null)
      }
    }
    dynamic "resume_cluster" {
      #This loop will execute only if the value of scheduled_actions is 'resume_cluster"
      for_each = can(each.value.resume_cluster) ? [each.value.resume_cluster] : []

      content {
        cluster_identifier = var.cluster_identifier
      }
    }
  }
}