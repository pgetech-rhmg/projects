
##### Cluster variables #####
variable "name" {
  description = "Name of the job flow"
  type        = string
}

variable "release_label" {
  description = "Release label for the Amazon EMR release."
  type        = string
  default     = null

  validation {
    condition = (
      var.release_label == null || 
      can(regex("^emr-[0-9]+\\.[0-9]+\\.[0-9]+$", var.release_label))
    )
    error_message = "release_label must be null or follow the format 'emr-x.y.z', e.g., emr-6.6.0"
  }
}

variable "release_label_filters" {
  description = "Map of release label filters used to lookup a release label"
  type = map(object({
    application = optional(string)
    prefix      = optional(string)
  }))
  default = {
    default = {
      prefix = "emr-6"
    }
  }
}

variable "region" {
  description = "Region where this resource will be managed. Defaults to the region set in the provider configuration."
  type        = string
  default     = null

  validation {
    condition     = var.region == null || can(regex("^(us|eu|ap|sa|ca|me|af)-[a-z]+-\\d$", var.region))
    error_message = "Region must be null or a valid AWS region like us-west-2, eu-central-1, ap-southeast-1, etc."
  }
}

variable "additional_info" {
  description = "JSON string for selecting additional features such as adding proxy information. Note: Currently there is no API to retrieve the value of this argument after EMR cluster creation from provider, therefore Terraform cannot detect drift from the actual EMR cluster if its value is changed outside Terraform"
  type        = string
  default     = null
}

variable "applications" {
  description = "A case-insensitive list of applications for Amazon EMR to install and configure when launching the cluster"
  type        = list(string)
  default     = []
}

variable "auto_termination_policy" {
  description = "An auto-termination policy for an Amazon EMR cluster. An auto-termination policy defines the amount of idle time in seconds after which a cluster automatically terminates"
  type = object({
    idle_timeout = optional(number)
  })
  default     = null
}

variable "bootstrap_action" {
  description = "Ordered list of bootstrap actions that will be run before Hadoop is started on the cluster nodes"
  type = list(object({
    args = optional(list(string))
    name = string
    path = string
  }))
  default = null
}

variable "configurations" {
  description = "List of configurations supplied for the EMR cluster you are creating. Supply a configuration object for applications to override their default configuration"
  type        = string
  default     = null
}

variable "configurations_json" {
  description = "JSON string for supplying list of configurations for the EMR cluster"
  type        = string
  default     = null
}
  
variable "core_instance_fleet" {
  description = "Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the core node type. Cannot be specified if any `core_instance_group` configuration blocks are set"
  type = object({
    name                      = optional(string)
    target_on_demand_capacity = optional(number)
    target_spot_capacity      = optional(number)

    instance_type_configs = optional(list(object({
  
      instance_type     = string
      weighted_capacity = optional(number)

      bid_price                                  = optional(string)
      bid_price_as_percentage_of_on_demand_price = optional(number)

      configurations = optional(list(object({
        classification = optional(string)
        properties     = optional(map(string))
      })))

      ebs_config = optional(list(object({
        iops                 = optional(number)
        size                 = optional(number)
        type                 = optional(string)
        volumes_per_instance = optional(number)
      })))
    })))

    launch_specifications = optional(object({
      on_demand_specification = optional(object({
        allocation_strategy = optional(string)
      }))

      spot_specification = optional(object({
        allocation_strategy      = optional(string)
        block_duration_minutes   = optional(number)
        timeout_action           = optional(string)
        timeout_duration_minutes = optional(number)
      }))
    }))
  })

  default = null
  
  validation {
    condition = (
      var.core_instance_fleet == null ||
      alltrue([
        for config in var.core_instance_fleet.instance_type_configs : (
          config.ebs_config == null || alltrue([
            for ebs in config.ebs_config : contains(["gp3", "gp2", "io1", "io2", "standard", "st1", "sc1"], ebs.type)
          ])
        )
      ])
    )
    error_message = "All EBS volume types must be one of: gp3, gp2, io1, io2, standard, st1, or sc1."
  }

  validation {
    condition = (
      var.core_instance_fleet == null ||
      try(var.core_instance_fleet.launch_specifications, null) == null ||
      try(var.core_instance_fleet.launch_specifications.spot_specification, null) == null ||
      (
        try(var.core_instance_fleet.launch_specifications.spot_specification.timeout_duration_minutes, 0) >= 5 &&
        try(var.core_instance_fleet.launch_specifications.spot_specification.timeout_duration_minutes, 0) <= 1440
      )
    )
    error_message = "Spot provisioning timeout_duration_minutes must be between 5 and 1440."
  }

  validation {
    condition = (
      var.core_instance_fleet == null ||
      try(var.core_instance_fleet.launch_specifications, null) == null ||
      try(var.core_instance_fleet.launch_specifications.spot_specification, null) == null ||
      contains(["TERMINATE_CLUSTER", "SWITCH_TO_ON_DEMAND"], try(var.core_instance_fleet.launch_specifications.spot_specification.timeout_action, ""))
    )
    error_message = "timeout_action must be either TERMINATE_CLUSTER or SWITCH_TO_ON_DEMAND."
  }

  validation {
    condition = (
      var.core_instance_fleet == null ||
      try(var.core_instance_fleet.launch_specifications, null) == null ||
      try(var.core_instance_fleet.launch_specifications.spot_specification, null) == null ||
      contains(["capacity-optimized", "diversified", "lowest-price", "price-capacity-optimized"], try(var.core_instance_fleet.launch_specifications.spot_specification.allocation_strategy, ""))
    )
    error_message = "spot_specification.allocation_strategy must be one of capacity-optimized, diversified, lowest-price, or price-capacity-optimized."
  }

  validation {
    condition = (
      var.core_instance_fleet == null ||
      try(var.core_instance_fleet.launch_specifications, null) == null ||
      try(var.core_instance_fleet.launch_specifications.on_demand_specification, null) == null ||
      try(var.core_instance_fleet.launch_specifications.on_demand_specification.allocation_strategy, "") == "lowest-price"
    )
    error_message = "on_demand_specification.allocation_strategy must be 'lowest-price'."
  }
}

variable "core_instance_group" {
  description = "Configuration block to use an [Instance Group] for the core node type"
  type = object({
    autoscaling_policy = optional(string)
    bid_price          = optional(string)

    ebs_config = optional(list(object({
      iops                 = optional(number)
      size                 = optional(number)
      throughput           = optional(number)
      type                 = optional(string)
      volumes_per_instance = optional(number)
    })))

    instance_count = optional(number)
    instance_type  = string
    name           = optional(string)
  })
  default     = null

  validation {
    condition     = var.core_instance_group == null || try(contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.core_instance_group.ebs_config[0].type), true)
    error_message = "ebs_config.type must be one of: gp2, gp3, io1, io2, st1, sc1."
  }

  validation {
    condition     = var.core_instance_group == null || try(length(var.core_instance_group.instance_type) > 0, true)
    error_message = "instance_type is required and cannot be empty."
  }
}

variable "custom_ami_id" {
  description = "Custom Amazon Linux AMI for the cluster (instead of an EMR-owned AMI). Available in Amazon EMR version 5.7.0 and later"
  type        = string
  default     = null
}

variable "ebs_root_volume_size" {
  description = "Size in GiB of the EBS root device volume of the Linux AMI that is used for each EC2 instance. Available in Amazon EMR version 4.x and later"
  type        = number
  default     = null
}

variable "ec2_attributes" {
  description = "Attributes for the Amazon EC2 instances running the EMR job flow."
  type = object({
    additional_master_security_groups = optional(string)
    additional_slave_security_groups  = optional(string)
    emr_managed_master_security_group = optional(string)
    emr_managed_slave_security_group  = optional(string)
    instance_profile                  = optional(string)
    key_name                          = optional(string)
    service_access_security_group     = optional(string)
    subnet_id                         = optional(string)
    subnet_ids                        = optional(list(string))
  })
  default = null

  validation {
    condition     = var.ec2_attributes.subnet_id == null || can(regex("^subnet-[a-zA-Z0-9]+$", var.ec2_attributes.subnet_id))
    error_message = "If provided, subnet_id must be a valid VPC subnet ID (e.g., subnet-123abc456)."
  }

  validation {
    condition     = var.ec2_attributes.subnet_ids == null || alltrue([for s in var.ec2_attributes.subnet_ids : can(regex("^subnet-[a-zA-Z0-9]+$", s))])
    error_message = "All subnet_ids must be valid VPC subnet IDs (e.g., subnet-123abc456)."
  }

  validation {
    condition     = var.ec2_attributes.additional_master_security_groups == null || can(regex("^sg-[a-zA-Z0-9,]+$", var.ec2_attributes.additional_master_security_groups))
    error_message = "additional_master_security_groups must be a comma-separated list of valid security group IDs (e.g., sg-123abc456,sg-789xyz123)."
  }

  validation {
    condition     = var.ec2_attributes.additional_slave_security_groups == null || can(regex("^sg-[a-zA-Z0-9,]+$", var.ec2_attributes.additional_slave_security_groups))
    error_message = "additional_slave_security_groups must be a comma-separated list of valid security group IDs (e.g., sg-123abc456,sg-789xyz123)."
  }
}

variable "keep_job_flow_alive_when_no_steps" {
  description = "Switch on/off run cluster with no steps or when all steps are complete (default is on)"
  type        = bool
  default     = null
}

variable "kerberos_attributes" {
  description = "Kerberos configuration for the cluster."
  type = object({
    ad_domain_join_password              = optional(string)
    ad_domain_join_user                  = optional(string)
    cross_realm_trust_principal_password = optional(string)
    kdc_admin_password                   = string
    realm                                = string
  })
  default = null

  validation {
    condition     = var.kerberos_attributes == null || try(length(var.kerberos_attributes.realm) > 0, true)
    error_message = "The 'realm' must be a non-empty string (e.g., EC2.INTERNAL)."
  }

  validation {
    condition     = var.kerberos_attributes == null || try(length(var.kerberos_attributes.kdc_admin_password) > 0, true)
    error_message = "The 'kdc_admin_password' must be provided and cannot be empty."
  }

  validation {
    condition     = var.kerberos_attributes == null || try(
      (var.kerberos_attributes.ad_domain_join_password == null && var.kerberos_attributes.ad_domain_join_user == null)
      || (var.kerberos_attributes.ad_domain_join_password != null && var.kerberos_attributes.ad_domain_join_user != null), true
    )
    error_message = "If 'ad_domain_join_user' is provided, 'ad_domain_join_password' must also be provided (and vice versa)."
  }

  validation {
    condition     = var.kerberos_attributes == null || try(
      var.kerberos_attributes.cross_realm_trust_principal_password == null
      || length(var.kerberos_attributes.cross_realm_trust_principal_password) > 0, true
    )
    error_message = "If 'cross_realm_trust_principal_password' is set, it cannot be empty."
  }
}

variable "list_steps_states" {
  description = "List of [step states](https://docs.aws.amazon.com/emr/latest/APIReference/API_StepStatus.html) used to filter returned steps"
  type        = list(string)
  default     = []
}

variable "log_encryption_kms_key_id" {
  description = "AWS KMS customer master key (CMK) key ID or arn used for encrypting log files. This attribute is only available with EMR version 5.30.0 and later, excluding EMR 6.0.0"
  type        = string
  default     = null
}

variable "log_uri" {
  description = "S3 bucket to write the log files of the job flow. If a value is not provided, logs are not created"
  type        = string
  default     = null
}

variable "master_instance_fleet" {
  description = "Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the master node type. Cannot be specified if any `master_instance_group` configuration blocks are set"
  type = object({
    name                       = optional(string)
    target_on_demand_capacity = optional(number)
    target_spot_capacity      = optional(number)

    instance_type_configs = optional(list(object({
      instance_type                             = string
      weighted_capacity                         = optional(number)
      bid_price                                 = optional(string)
      bid_price_as_percentage_of_on_demand_price = optional(number)

      configurations = optional(list(object({
        classification = optional(string)
        properties     = optional(map(string))
      })))

      ebs_config = optional(list(object({
        iops                 = optional(number)
        size                 = optional(number)
        type                 = optional(string)
        volumes_per_instance = optional(number)
      })))
    })))

    launch_specifications = optional(object({
      on_demand_specification = optional(object({
        allocation_strategy = optional(string)
      }))
      spot_specification = optional(object({
        allocation_strategy      = optional(string)
        block_duration_minutes   = optional(number)
        timeout_action           = optional(string)
        timeout_duration_minutes = optional(number)
      }))
    }))
  })
  default = null
}

variable "master_instance_group" {
  description = "Configuration block to use an [Instance Group](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-group-configuration.html#emr-plan-instance-groups) for the [master node type](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html#emr-plan-master)"
  type = object({
    bid_price      = optional(string)
    instance_count = optional(number)
    instance_type  = string
    name           = optional(string)

    ebs_config = optional(list(object({
      iops                 = optional(number)
      size                 = optional(number)
      throughput           = optional(number)
      type                 = optional(string)
      volumes_per_instance = optional(number)
    })))
  })
  default = null
}

variable "placement_group_config" {
  description = "The specified placement group configuration"
  type = list(object({
    instance_role      = string
    placement_strategy = optional(string)
  }))
  default = null
}

variable "scale_down_behavior" {
  description = "Way that individual Amazon EC2 instances terminate when an automatic scale-in activity occurs or an instance group is resized"
  type        = string
  default     = "TERMINATE_AT_TASK_COMPLETION"
}

variable "security_configuration_name" {
  description = "Name of the security configuration to create, or attach if `create_security_configuration` is `false`. Only valid for EMR clusters with `release_label` 4.8.0 or greater"
  type        = string
  default     = null
}

variable "step" {
  description = "Steps to run when creating the cluster"
  type = list(object({
    name             = string
    action_on_failure = string
    hadoop_jar_step = optional(object({
      jar        = string
      args       = optional(list(string))
      main_class = optional(string)
      properties = optional(map(string))
    }))
  }))

  default = []
}

variable "step_concurrency_level" {
  description = "Number of steps that can be executed concurrently. You can specify a maximum of 256 steps. Only valid for EMR clusters with `release_label` 5.28.0 or greater (default is 1)"
  type        = number
  default     = null
}

variable "termination_protection" {
  description = "Switch on/off termination protection (default is `false`, except when using multiple master nodes). Before attempting to destroy the resource when termination protection is enabled, this configuration must be applied with its value set to `false`"
  type        = bool
  default     = null
}

variable "unhealthy_node_replacement" {
  description = "Whether whether Amazon EMR should gracefully replace core nodes that have degraded within the cluster. Default value is `false`"
  type        = bool
  default     = null
}

variable "visible_to_all_users" {
  description = "Whether the job flow is visible to all IAM users of the AWS account associated with the job flow. Default value is `true`"
  type        = bool
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

##### # Task Instance Fleet #####

variable "task_instance_fleet" {
  description = "Configuration block to use an [Instance Fleet](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html) for the task node type. Cannot be specified if any `task_instance_group` configuration blocks are set"
  type = object({
    name                      = optional(string)
    target_on_demand_capacity = optional(number)
    target_spot_capacity      = optional(number)

    instance_type_configs = optional(list(object({
      instance_type                              = string
      weighted_capacity                          = optional(number)
      bid_price                                  = optional(string)
      bid_price_as_percentage_of_on_demand_price = optional(number)

      configurations = optional(list(object({
        classification = optional(string)
        properties     = optional(map(string))
      })))

      ebs_config = optional(list(object({
        iops                 = optional(number)
        size                 = optional(number)
        type                 = optional(string)
        volumes_per_instance = optional(number)
      })))
    })))

    launch_specifications = optional(object({
      on_demand_specification = optional(object({
        allocation_strategy = optional(string)
      }))
      spot_specification = optional(object({
        allocation_strategy      = optional(string)
        block_duration_minutes   = optional(number)
        timeout_action           = optional(string)
        timeout_duration_minutes = optional(number)
      }))
    }))
  })

  default = null
}

##### Task Instance Group #####

variable "task_instance_group" {
  description = "Configuration block to use an [Instance Group](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-group-configuration.html#emr-plan-instance-groups) for the [task node type](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html#emr-plan-master)"
  type = object({
    autoscaling_policy  = optional(string) 
    bid_price           = optional(string)
    configurations_json = optional(string)
    ebs_optimized       = optional(bool)
    instance_count      = optional(number)
    instance_type       = string
    name                = optional(string)

    ebs_config = optional(list(object({
      iops                 = optional(number)
      size                 = optional(number)
      type                 = optional(string)
      volumes_per_instance = optional(number)
    })))
  })

  default = null
}

##### Managed Scaling Policy #####

variable "managed_scaling_policy" {
  description = "Compute limit configuration for a [Managed Scaling Policy](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-scaling.html)"
  type = object({
    maximum_capacity_units          = number
    maximum_core_capacity_units     = optional(number)
    maximum_ondemand_capacity_units = optional(number)
    minimum_capacity_units          = number
    unit_type                       = string
  })
  default = null
}

##### Security Configuration #####

variable "create_security_configuration" {
  description = "Determines whether a security configuration is created"
  type        = bool
  default     = false
}

variable "security_configuration_use_name_prefix" {
  description = "Determines whether `security_configuration_name` is used as a prefix"
  type        = bool
  default     = true
}

variable "security_configuration" {
  description = "Security configuration to create, or attach if `create_security_configuration` is `false`. Only valid for EMR clusters with `release_label` 4.8.0 or greater"
  type        = string
  default     = null
}

##### Common IAM Role #####

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

##### Service IAM Role #####
variable "create_service_iam_role" {
  description = "Determines whether the service IAM role should be created"
  type        = bool
  default     = true
}

variable "service_iam_role_arn" {
  description = "The ARN of an existing IAM role to use for the service"
  type        = string
  default     = null

  validation {
    condition     = var.service_iam_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.service_iam_role_arn))
    error_message = "The IAM role ARN must be in the format: arn:aws:iam::<account_id>:role/<role_name>"
  }
}

variable "service_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "service_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "service_iam_role_policies" {
  description = "Map of IAM policies to attach to the service role"
  type        = map(string)
  default     = {}
}

variable "service_pass_role_policy_name" {
  description = "Name to use on IAM policy created"
  type        = string
  default     = null
}

variable "service_pass_role_policy_description" {
  description = "Description of the policy"
  type        = string
  default     = null
}

##### Autoscaling IAM Role  #####

variable "create_autoscaling_iam_role" {
  description = "Determines whether the autoscaling IAM role should be created"
  type        = bool
  default     = true
}

variable "autoscaling_iam_role_arn" {
  description = "The ARN of an existing IAM role to use for the service"
  type        = string
  default     = null

  validation {
    condition     = var.autoscaling_iam_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.autoscaling_iam_role_arn))
    error_message = "The IAM role ARN must be in the format: arn:aws:iam::<account_id>:role/<role_name>"
  }
}

variable "autoscaling_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "autoscaling_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

##### Instance Profile #####

variable "create_iam_instance_profile" {
  description = "Determines whether the EC2 IAM role/instance profile should be created"
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Name to use on EC2 IAM role/instance profile created"
  type        = string
  default     = null
}

variable "iam_instance_profile_role_service" {
  description = "Aws service of the EMR EC2 IAM role/instance profile"
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
}

variable "iam_instance_profile_description" {
  description = "Description of the EC2 IAM role/instance profile"
  type        = string
  default     = null
}

variable "iam_instance_profile_policies" {
  description = "Map of IAM policies to attach to the EC2 IAM role/instance profile"
  type        = map(string)
  default     = { AmazonElasticMapReduceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role" }
}

variable "iam_instance_profile_role_arn" {
  description = "The ARN of an existing IAM role to use if passing in a custom instance profile and creating a service role"
  type        = string
  default     = null
}

##### Managed Security Group #####

variable "create_managed_security_groups" {
  description = "Determines whether managed security groups are created"
  type        = bool
  default     = true
}

variable "managed_security_group_name" {
  description = "Name to use on manged security group created. Note - `-master`, `-slave`, and `-service` will be appended to this name to distinguish"
  type        = string
  default     = null
}

variable "managed_security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the Amazon Virtual Private Cloud (Amazon VPC) where the security groups will be created"
  type        = string
  default     = ""
}

##### Managed Master Security Group #####

variable "master_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "Managed master security group"
}

variable "master_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type = map(object({
    from_port = number
    to_port   = number
    protocol = optional(string, "tcp")
    type     = optional(string, "egress")
    description              = optional(string)
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    self                     = optional(bool)
    source_security_group_id = optional(string)
    source_slave_security_group   = optional(bool, false)
    source_service_security_group = optional(bool, false)
  }))

  default = {
    "default" = {
      description      = "Allow all egress traffic"
      type             = "egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    "ingress_self_all" = {
      description = "Allow all traffic from master nodes to master nodes"
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      self        = true
    }
    "ingress_self_udp" = {
      description = "Allow all UDP traffic from master nodes to master nodes"
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      self        = true
    }
    "ingress_self_icmp" = {
      description = "Allow ICMP traffic from master nodes to master nodes"
      type        = "ingress"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      self        = true
    }
    "ingress_from_slave_all" = {
      description                = "Allow all traffic from slave nodes"
      type                       = "ingress"
      from_port                  = 0
      to_port                    = 65535
      protocol                   = "tcp"
      source_slave_security_group = true
    }
    "ingress_from_slave_udp" = {
      description                = "Allow all UDP traffic from slave nodes"
      type                       = "ingress"
      from_port                  = 0
      to_port                    = 65535
      protocol                   = "udp"
      source_slave_security_group = true
    }
    "ingress_from_slave_icmp" = {
      description                = "Allow ICMP from slave nodes"
      type                       = "ingress"
      from_port                  = -1
      to_port                    = -1
      protocol                   = "icmp"
      source_slave_security_group = true
    }
    "ingress_from_service_8443" = {
      description              = "Allow traffic from EMR service on port 8443"
      type                     = "ingress"
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      source_service_security_group = true
    }
  }
}

##### Managed Slave Security Group #####

variable "slave_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "Managed slave security group"
}

variable "slave_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default = {
    "default" = {
      description      = "Allow all egress traffic"
      type             = "egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    "ingress_self_all" = {
      description = "Allow all traffic from slave nodes to slave nodes"
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      self        = true
    }
    "ingress_self_udp" = {
      description = "Allow all UDP traffic from slave nodes to slave nodes"
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      self        = true
    }
    "ingress_self_icmp" = {
      description = "Allow ICMP traffic from slave nodes to slave nodes"
      type        = "ingress"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      self        = true
    }
    "ingress_from_master_all" = {
      description                 = "Allow all traffic from master nodes"
      type                        = "ingress"
      from_port                   = 0
      to_port                     = 65535
      protocol                    = "tcp"
      source_master_security_group = true
    }
    "ingress_from_master_udp" = {
      description                 = "Allow all UDP traffic from master nodes"
      type                        = "ingress"
      from_port                   = 0
      to_port                     = 65535
      protocol                    = "udp"
      source_master_security_group = true
    }
    "ingress_from_master_icmp" = {
      description                 = "Allow ICMP from master nodes"
      type                        = "ingress"
      from_port                   = -1
      to_port                     = -1
      protocol                    = "icmp"
      source_master_security_group = true
    }
    "ingress_from_service_8443" = {
      description              = "Allow traffic from EMR service on port 8443"
      type                     = "ingress"
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      source_service_security_group = true
    }
  }
}

##### Managed Service Access Security Group #####


variable "is_private_cluster" {
  description = "Identifies whether the cluster is created in a private subnet"
  type        = bool
  default     = true
}

variable "service_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = "Managed service access security group"
}

variable "service_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default     = {}
}