variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

#variables for Tags
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

##### Network Configuration #####

variable "vpc_id" {
  type        = string
  description = "Id of vpc stored in aws_ssm_parameter"
}

variable "subnet_id1_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 1"
}

variable "subnet_id2_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 2"
}

variable "subnet_id3_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 3"
}


##### Cluster variables #####

variable "name" {
  description = "Name of the job flow"
  type        = string
}

variable "release_label_filters" {
  description = "Map of release label filters used to lookup a release label"
  type = map(object({
    application = optional(string)
    prefix      = optional(string)
  }))
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

variable "configurations_json" {
  description = "JSON string for supplying list of configurations for the EMR cluster"
  type        = string
  default     = null
}

variable "service_iam_role_policies" {
  description = "Map of IAM policies to attach to the EMR service role"
  type        = map(string)
  default     = {}
}

variable "iam_instance_profile_policies" {
  description = "Map of IAM policies to attach to the EC2 IAM role/instance profile"
  type        = map(string)
  default     = {}
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
}

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
  default = {}
}

variable "keep_job_flow_alive_when_no_steps" {
  description = "Switch on/off run cluster with no steps or when all steps are complete (default is on)"
  type        = bool
  default     = null
}

variable "list_steps_states" {
  description = "List of [step states](https://docs.aws.amazon.com/emr/latest/APIReference/API_StepStatus.html) used to filter returned steps"
  type        = list(string)
  default     = []
}

variable "log_uri" {
  description = "S3 bucket to write the log files of the job flow. If a value is not provided, logs are not created"
  type        = string
  default     = null
}

variable "scale_down_behavior" {
  description = "Way that individual Amazon EC2 instances terminate when an automatic scale-in activity occurs or an instance group is resized"
  type        = string
  default     = "TERMINATE_AT_TASK_COMPLETION"
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

variable "instance_profile" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
  default     = "EMR_EC2_DefaultRole"
}

variable "optional_tags" {
  description = "Optional tags for resources"
  type = map(string)
  default = {}
}

##### VPC Endpoint variables #####
  ### S3 Endpoint ###
variable "service_name_s3" {
  type        = string
  description = "The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook"
  default     = null
}

variable "route_table_ids" {
  type        = list(any)
  description = "The route table ids"
  default     = null
}

  ### emr Endpoint ###

variable "service_name_emr" {
  type        = string
  description = "The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook"
  default     = null
}

variable "private_dns_enabled_emr" {
  type        = bool
  description = "Whether or not to associate a private hosted zone with the specified VPC"
}

  ### sts Endpoint ###

variable "service_name_sts" {
  type        = string
  description = "The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook"
  default     = null
}

variable "private_dns_enabled_sts" {
  type        = bool
  description = "Whether or not to associate a private hosted zone with the specified VPC"
}

