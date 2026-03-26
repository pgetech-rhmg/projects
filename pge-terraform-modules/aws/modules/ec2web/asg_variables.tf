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

variable "launch_template_name" {
  description = "Name of the launch template."
  type        = string
}

variable "launch_template_version" {
  description = "Version of the launch template."
  type        = string
  default     = "$Default"
  validation {
    condition = anytrue([
      can(regex("^[0-9A-Za-z]+$", var.launch_template_version)),
      var.launch_template_version == "$Latest",
    var.launch_template_version == "$Default"])
    error_message = "Error! values for launch_template_version should be $Latest and $Default."
  }
}

variable "iam_instance_profile" {
  description = "The name attribute of the IAM instance profile to associate with launched instances"
  type        = string
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
  default     = 0
  validation {
    condition     = (var.asg_max_instance_lifetime == 0 || var.asg_max_instance_lifetime >= 86400 && var.asg_max_instance_lifetime <= 31536000)
    error_message = "Error! The value must be 0 or between 86400 and 31536000."
  }
}

variable "warm_pool" {
  description = "If this block is configured, add a Warm Pool to the specified Auto Scaling group"
  type        = list(any)
  default     = []
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

# Variables for autoscaling attachment

variable "lb_target_group_arn" {
  description = "Arn of the load balancer target group."
  type        = list(map(string))
  default     = []
  validation {
    condition = alltrue([
      for i in var.lb_target_group_arn : can(regex("^arn:aws:elasticloadbalancing:\\w+(?:-\\w+)+:[[:digit:]]{12}:targetgroup/([a-zA-Z0-9])+(.*)$", i.lb_target_group_arn))
    ])
    error_message = "Error! enter a valid target group arn."
  }
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "image_id" {
  type = string
}

variable "user_data" {
  description = " The user data to provide when launching the instance "
  type        = string
  default     = null
}

variable "capacity_reservation_specification" {
  type    = any
  default = null
}

variable "disable_api_stop" {
  type    = bool
  default = true
}

variable "disable_api_termination" {
  type    = bool
  default = true
}

variable "ebs_optimized" {
  type    = bool
  default = false
}

variable "elastic_gpu_specifications" {
  type    = map(string)
  default = null
}

variable "instance_initiated_shutdown_behavior" {
  type    = string
  default = "stop"
}

variable "kernel_id" {
  type    = string
  default = ""
}

variable "ram_disk_id" {
  type    = string
  default = ""
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type        = list(any)
  default     = []
}

variable "network_interfaces" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(any)
  default     = []
}

variable "cpu_options" {
  description = "The CPU options for the instance"
  type        = map(string)
  default     = {}
}

# variable "asg_security_groups" {
#   description = "A list of security group IDs to associate"
#   type        = list(string)
# }

variable "instance_market_options" {
  description = "The market (purchasing) option for the instance"
  type = map(object({
    market_type = string
    spot_options = object({
      block_duration_minutes         = number
      instance_interruption_behavior = string
      max_price                      = number
      spot_instance_type             = string
      valid_until                    = number
    })
  }))
  default = {}
}

variable "tag_specifications" {
  description = "The tags to apply to the resources during launch"
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))

  default = [{
    resource_type = "instance"
    tags          = {}
  }]
}

variable "create_launch_template" {
  description = "Determines whether to create launch template or not"
  type        = bool
  default     = true
}

variable "launch_template" {
  description = "Name of an existing launch template to be used (created outside of this module)"
  type        = string
  default     = null
}

variable "use_mixed_instances_policy" {
  description = "Determines whether to use a mixed instances policy in the autoscaling group or not"
  type        = bool
  default     = false
}

variable "placement" {
  description = "The placement of the instance"
  type        = map(string)
  default     = {}
}

variable "credit_specification" {
  description = "Customize the credit specification of the instance"
  type        = map(string)
  default     = {}
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance"
  type        = map(string)
  default     = {}
}

variable "instance_name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = "asg_launch_template"
}