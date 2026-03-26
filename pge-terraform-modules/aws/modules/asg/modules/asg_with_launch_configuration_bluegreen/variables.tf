# Variables for tags

variable "tags" {
  description = "Set of maps containing resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}


# variables for autoscaling group
variable "asg_name" {
  description = "The name of the Auto Scaling Group"
  type        = string
  default     = null
}

variable "asg_name_prefix" {
  description = "Creates a unique name beginning with the specified prefix."
  type        = string
  default     = null
}


variable "asg_max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_availability_zones" {
  description = "A list of one or more availability zones for the group"
  type        = list(string)
  default     = null
}

variable "asg_capacity_rebalance" {
  description = "Indicates whether capacity rebalance is enabled."
  type        = bool
  default     = false
}

variable "asg_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  type        = number
  default     = null
}

variable "asg_health_check_grace_period" {
  description = "Time after instance comes into service before checking health."
  type        = number
  default     = 300
}

variable "asg_health_check_type" {
  description = "Controls how health checking is done."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.asg_health_check_type == null,
      var.asg_health_check_type == "EC2",
    var.asg_health_check_type == "ELB"])
    error_message = "Error! values for asg health check type should be EC2 and ELB."
  }
}

variable "asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
  default     = null
}

variable "asg_force_delete" {
  description = "Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate."
  type        = bool
  default     = false
}

variable "asg_load_balancers" {
  description = "A list of elastic load balancer names to add to the autoscaling group names"
  type        = list(string)
  default     = null
}

variable "asg_vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
  default     = null
}

variable "asg_target_group_arns" {
  description = "A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing"
  type        = list(string)
  default     = null
}

variable "asg_termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated."
  type        = string
  default     = "Default"
  validation {
    condition     = contains(["OldestInstance", "NewestInstance", "OldestLaunchConfiguration", "ClosestToNextInstanceHour", "OldestLaunchTemplate", "AllocationStrategy", "Default"], var.asg_termination_policies)
    error_message = "Valid values for asg termination policies are  OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy and Default."
  }
}

variable "asg_suspended_processes" {
  description = "A list of processes to suspend for the Auto Scaling Group"
  type        = list(string)
  default     = null
  validation {
    condition = anytrue([
      var.asg_suspended_processes == null,
      var.asg_suspended_processes == "Launch",
      var.asg_suspended_processes == "Terminate",
      var.asg_suspended_processes == "HealthCheck",
      var.asg_suspended_processes == "ReplaceUnhealthy",
      var.asg_suspended_processes == "AZRebalance",
      var.asg_suspended_processes == "AlarmNotification",
      var.asg_suspended_processes == "ScheduledActions",
    var.asg_suspended_processes == "AddToLoadBalancer"])
    error_message = "Error! values for suspended processes should be Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions and AddToLoadBalancer."
  }
}

variable "asg_placement_group" {
  description = "The name of the placement group into which you'll launch your instances"
  type        = string
  default     = null
}

variable "asg_enabled_metrics" {
  description = "A list of metrics to collect"
  type        = list(string)
  default     = null
}

variable "asg_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  type        = string
  default     = null
}

variable "asg_min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances from this Auto Scaling Group to show up healthy in the ELB only on creation"
  type        = number
  default     = null
}

variable "asg_wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances from this Auto Scaling Group in all attached load balancers on both create and update operations"
  type        = number
  default     = null
}

variable "asg_protect_from_scale_in" {
  description = "Allows setting instance protection"
  type        = string
  default     = null
}

variable "asg_service_linked_role_arn" {
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  type        = string
  default     = null
}

variable "asg_max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service"
  type        = number
  default     = 86400
  validation {
    condition     = (var.asg_max_instance_lifetime >= 86400 && var.asg_max_instance_lifetime <= 31536000)
    error_message = "Error! The value must be between 86400 and 31536000."
  }
}

variable "warm_pool" {
  description = "If this block is configured, add a Warm Pool to the specified Auto Scaling group"
  type        = list(any)
  default     = []
}

variable "strategy" {
  description = "The strategy to use for instance refresh"
  type        = string
  default     = "Rolling"
}

variable "initial_lifecycle_hooks" {
  description = "One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. The syntax is exactly the same as the separate `aws_autoscaling_lifecycle_hook` resource, without the `autoscaling_group_name` attribute. Please note that this will only work when creating a new Auto Scaling Group. For all other use-cases, please use `aws_autoscaling_lifecycle_hook` resource"
  type        = list(map(string))
  default     = []
}

variable "triggers" {
  description = "Set of additional property names that will trigger an Instance Refresh"
  type        = list(string)
  default     = null
}

variable "checkpoint_delay" {
  description = "The number of seconds to wait after a checkpoint."
  type        = string
  default     = null
}

variable "checkpoint_percentages" {
  description = "List of percentages for each checkpoint."
  type        = list(string)
  default     = null
}

variable "instance_warmup" {
  description = "The number of seconds until a newly launched instance is configured and ready to use."
  type        = string
  default     = null
}

variable "min_healthy_percentage" {
  description = "The amount of capacity in the Auto Scaling group that must remain healthy during an instance refresh to allow the operation to continue, as a percentage of the desired capacity of the Auto Scaling group."
  type        = string
  default     = 90
}


# Variables for Launch Configuration
variable "config_name" {
  description = "The name of the launch configuration"
  type        = string
  default     = null
}
variable "use_config_name_prefix" {
  description = "Creates a unique name beginning with the specified prefix"
  type        = bool
  default     = false
}

variable "image_id" {
  description = "The EC2 image ID to launch"
  type        = string
  validation {
    condition = anytrue([
      can(regex("^ami-\\w+", var.image_id))
    ])
    error_message = "Image id is required and allowed format of the image id  is ami-#################."
  }
}

variable "instance_type" {
  description = "The size of instance to launch"
  type        = string
}

variable "iam_instance_profile" {
  description = "The name attribute of the IAM instance profile to associate with launched instances"
  type        = string
  default     = null
}

variable "http_endpoint" {
  description = " The state of the metadata service"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.http_endpoint == null,
      var.http_endpoint == "enabled",
    var.http_endpoint == "disabled"])
    error_message = "Error! values for http endpoint should be enabled and disabled."
  }
}

variable "http_tokens" {
  description = " If session tokens are required"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.http_tokens == null,
      var.http_tokens == "optional",
    var.http_tokens == "required"])
    error_message = "Error! values for http tokens should be optional and required."
  }
}

variable "http_put_response_hop_limit" {
  description = "The desired HTTP PUT response hop limit for instance metadata requests"
  type        = string
  default     = null
}


variable "security_groups" {
  description = "A list of associated security group IDS"
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = " Associate a public ip address with an instance in a VPC."
  type        = string
  default     = null
}

variable "user_data" {
  description = " The user data to provide when launching the instance "
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = " Can be used instead of user_data to pass base64-encoded binary data directly "
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  type        = bool
  default     = false
}

variable "volume_type" {
  description = "The type of volume"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "gp2", "gp3", "st1", "sc1", "io1"], var.volume_type)
    error_message = "Valid values for volume type are  standard, gp2, gp3, st1, sc1 and io1."
  }
}

variable "volume_size" {
  description = "The size of the volume in gigabytes."
  type        = number
  default     = null
}

variable "iops" {
  description = "The amount of provisioned IOPS."
  type        = number
  default     = null
}

variable "throughput" {
  description = "The throughput (MiBps) to provision for a gp3 volume."
  type        = number
  default     = null
}

variable "delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination ."
  type        = bool
  default     = true
}

variable "device_name" {
  description = "The name of the device to mount."
  type        = string
  default     = null
}

variable "snapshot_id" {
  description = "The Snapshot ID to mount."
  type        = string
  default     = null
}

variable "ebs_volume_type" {
  description = "The type of volume"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "gp2", "gp3", "st1", "sc1", "io1"], var.ebs_volume_type)
    error_message = "Valid values for ebs volume type are  standard, gp2, gp3, st1, sc1 and io1."
  }
}

variable "ebs_volume_size" {
  description = "The size of the volume in gigabytes."
  type        = number
  default     = null
}

variable "ebs_iops" {
  description = "The amount of provisioned IOPS."
  type        = number
  default     = null
}

variable "ebs_throughput" {
  description = "The throughput (MiBps) to provision for a gp3 volume."
  type        = number
  default     = null
}

variable "ebs_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination ."
  type        = bool
  default     = true
}

variable "no_device" {
  description = "Whether the device in the block device mapping of the AMI is suppressed."
  type        = bool
  default     = null
}

variable "ephemeral_device_name" {
  description = "The name of the block device to mount on the instance."
  type        = string
  default     = null
}

variable "ephemeral_virtual_name" {
  description = "The Instance Store Device Name."
  type        = string
  default     = null
}


variable "spot_price" {
  description = "The maximum price to use for reserving spot instances"
  type        = string
  default     = null
}

variable "placement_tenancy" {
  description = "The tenancy of the instance"
  type        = string
  default     = null
}

# Variables for autoscaling policy

variable "autoscaling_policy_name" {
  description = "The name of the Policy."
  type        = string
}

variable "policy_type" {
  description = "The policy type, either 'SimpleScaling' , 'StepScaling' or 'TargetTrackingScaling'. If this value isn't provided, AWS will default to 'SimpleScaling'."
  type        = string
  default     = "SimpleScaling"
  validation {
    condition     = contains(["SimpleScaling", "StepScaling", "TargetTrackingScaling"], var.policy_type)
    error_message = "Valid values for policy type are SimpleScaling, StepScaling and TargetTrackingScaling."
  }
}

variable "scaling_adjustment" {
  description = "The number of instances by which to scale. adjustment_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity."
  type        = number
  default     = null
}

variable "adjustment_type" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity."
  type        = string
  default     = null
}

variable "cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  type        = number
  default     = null
}

variable "estimated_instance_warmup" {
  description = "The estimated time, in seconds, until a newly launched instance will contribute CloudWatch metrics. Without a value, AWS will default to the group's specified cooldown period."
  type        = number
  default     = null
}