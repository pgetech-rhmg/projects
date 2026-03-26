/*
 * # AWS EC2Web Scheduler Submodule
 *
 * Terraform submodule which creates SAF2.0 EC2Web scheduled resource in AWS
 *
 * This module allows you to create schedules for an AWS Auto Scaling Group (ASG). You can define schedules for weekdays, weekends, and a default configuration
 *
 * **Important**: Start and stop times must be in 24HR format, and across different schedules should not overlap as this will cause Terraform to create duplicate schedules and lead to errors.
 * 
 * ASG must already exist to use this submodule to add schedules
 * 
 * ```
 * # invoke the module
 * module "scheduler" {
 *  source   = "../../modules/ec2web_scheduled"
 *  asg_name = module.ec2web_test.asg_name # Must be taken from existing ASG
 *  schedules = var.schedules
 * }
 * ```
 * 
 * Example schedules in terraform.auto.tfvars:
 * ```
 *  schedules = [
 *   {
 *     name = "test-schedule"
 *     # Start and Stop times must be in 24HR format (0:00-23:59)
 *     weekday_time_windows = [
 *       {
 *         min_size         = 5
 *         max_size         = 10
 *         desired_capacity = 5
 *         start_time       = "12:00"
 *         stop_time        = "14:00"
 *       },
 *       {
 *         min_size         = 3
 *         max_size         = 7
 *         desired_capacity = 3
 *         start_time       = "14:01" # 14:00 would result in error with above schedule as start and previous stop time coincide
 *         stop_time        = "15:30"
 *       }
 *     ]
 *     # Can leave time window empty if no schedule specified []
 *     weekend_time_windows = [
 *       {
 *         min_size         = 2
 *         max_size         = 4
 *         desired_capacity = 2
 *         start_time       = "00:00"
 *         stop_time        = "23:59" # example of full weekend
 *       }
 *     ]
 *     default_vals = {
 *       min_size         = 1
 *       max_size         = 2
 *       desired_capacity = 1
 *     }
 *   }
 * ]
 * ```


*/

#
# Filename    : modules/ec2web/ec2web_scheduled/main.tf
# Date        : 26 July 2024
# Author      : Pallavi Das (p4dn@pge.com)
# Last Update : 9 August 2024


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
  # Create schedule configurations for time windows
  # Note: Ensure that NO start time of a schedule coincides with the stop time of another schedule
  weekday_schedules = flatten([
    for schedule in var.schedules : [
      for window in schedule.weekday_time_windows : [
        # Weekday Time Windows
        {
          name             = replace("${schedule.name}-start-weekday-${window.start_time}", ":", "-")
          min_size         = window.min_size
          max_size         = window.max_size
          desired_capacity = window.desired_capacity
          recurrence       = format("%d %d * * 1-5", tonumber(split(":", window.start_time)[1]), tonumber(split(":", window.start_time)[0]))
        },
        {
          name             = replace("${schedule.name}-stop-weekday-${window.stop_time}", ":", "-")
          min_size         = schedule.default_vals.min_size
          max_size         = schedule.default_vals.max_size
          desired_capacity = schedule.default_vals.desired_capacity
          recurrence       = format("%d %d * * 1-5", tonumber(split(":", window.stop_time)[1]), tonumber(split(":", window.stop_time)[0]))
        }
      ]
    ]
  ])

  weekend_schedules = flatten([
    for schedule in var.schedules : [
      for window in schedule.weekend_time_windows : [
        # Weekend Time Windows
        {
          name             = replace("${schedule.name}-start-weekend-${window.start_time}", ":", "-")
          min_size         = window.min_size
          max_size         = window.max_size
          desired_capacity = window.desired_capacity
          recurrence       = format("%d %d * * 6-7", tonumber(split(":", window.start_time)[1]), tonumber(split(":", window.start_time)[0]))
        },
        {
          name             = replace("${schedule.name}-stop-weekend-${window.stop_time}", ":", "-")
          min_size         = schedule.default_vals.min_size
          max_size         = schedule.default_vals.max_size
          desired_capacity = schedule.default_vals.desired_capacity
          recurrence       = format("%d %d * * 6-7", tonumber(split(":", window.stop_time)[1]), tonumber(split(":", window.stop_time)[0]))
        }
      ]
    ]
  ])

  default_schedules = flatten([
    for schedule in var.schedules : [
      # Default Schedule for when no specific schedule is active
      {
        name             = "${schedule.name}-default"
        min_size         = schedule.default_vals.min_size
        max_size         = schedule.default_vals.max_size
        desired_capacity = schedule.default_vals.desired_capacity
        recurrence       = "0 0 * * *"
      }
    ]
  ])

  all_schedules = { for s in concat(local.weekday_schedules, local.weekend_schedules, local.default_schedules) : s.recurrence => s }
}

resource "aws_autoscaling_schedule" "schedule" {
  for_each               = { for s in local.all_schedules : s.name => s }
  scheduled_action_name  = each.key
  min_size               = each.value.min_size
  max_size               = each.value.max_size
  desired_capacity       = each.value.desired_capacity
  recurrence             = each.value.recurrence
  autoscaling_group_name = var.asg_name
  time_zone              = var.time_zone
}
