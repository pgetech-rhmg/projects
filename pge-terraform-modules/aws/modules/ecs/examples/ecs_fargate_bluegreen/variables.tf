variable "aws_region" {
  type        = string
  description = "AWS region"
}

# Variables for assume_role used in terraform.tf

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

# Variables for aws_ssm_parameter

variable "parameter_vpc_id_name" {
  type        = string
  description = "Id of vpc stored in aws_ssm_parameter"
  default     = "/vpc/id"
}

variable "parameter_subnet_id1_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
}

variable "docker_registry" {
  description = "Docker registry from which the image will be deployed"
  type        = string
  default     = "JFROG"
  validation {
    condition     = contains(["ECR", "JFROG"], var.docker_registry)
    error_message = "Valid values for docker registry are ECR or JFROG."
  }
}

variable "parameter_subnet_id2_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
}

variable "jfrog_credentials" {
  type        = string
  description = "Jfrog Credentials stored in the secrets"
  default     = "/jfrog/credentials"
}

# Variables for tags 

variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

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

# Variables for ecs_fargate

variable "cluster_name" {
  description = "Enter the name of the cluster"
  type        = string
}

variable "setting_value" {
  description = "The value to assign to the setting. Value values are enabled and disabled."
  type        = string
  default     = "enabled"
}

variable "ecs_cluster_capacity_providers" {
  description = "Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "ecs_default_cluster_capacity_provider" {
  description = "The short name of the capacity provider."
  type        = string
  default     = "FARGATE"
}

# Variables for ecs task definition

variable "requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
}

variable "memory" {
  description = "Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
}

# Variables for ecs service

variable "service_name" {
  description = "Provide name for the service"
  type        = string
}

variable "ecs_service_launch_type" {
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2."
  type        = string
}

variable "deployment_type" {
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS, EXTERNAL. Default: ECS."
  type        = string
}

variable "load_balancer" {
  description = "Configuration block for load balancers."
  type        = any
}


variable "availability_zone_rebalancing" {
  description = "Automatically redistributes tasks within a service across Availability Zones Valid values: ENABLED, DISABLED. Default: DISABLED."
  type        = string
  default     = "DISABLED"
}

# Variables for ecs account setting default

variable "ecs_account_name" {
  description = "Name of the account setting to set. Valid values are serviceLongArnFormat, taskLongArnFormat, containerInstanceLongArnFormat, awsvpcTrunking and containerInsights."
  type        = string
  default     = "taskLongArnFormat"
}

variable "ecs_account_setting_value" {
  description = "State of the setting. Valid values are enabled and disabled."
  type        = string
  default     = "enabled"
}

# Variables for security_group for ecs

variable "ecs_cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "ecs_cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "ecs_sg_description" {
  description = "vpc id for security group"
  type        = string
  default     = "Security group for example usage with ecs"
}

# Variables for IAM role of ecs

variable "ecs_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
  default     = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
}

variable "ecs_iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", "arn:aws:iam::aws:policy/AmazonECS_FullAccess"]
}

# Variable for load balancer

variable "lb_listener_http" {
  description = "A list of maps describing HTTP listeners for ALB."
  type        = any
}

variable "lb_target_group_name" {
  description = "Name of the target group for blue"
  type        = string
}

variable "lb_target_group_name_test" {
  description = "Name of the target group for green"
  type        = string
}

variable "target_group_target_type" {
  description = "Type of target that you must specify when registering targets with this target group"
  type        = string
}

variable "target_group_port" {
  description = " Port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
}

variable "target_group_port_test" {
  description = " Port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
}

# Variables for s3

variable "policy" {
  description = "Policy template file in json format "
  type        = string
  default     = "s3_policy.json"
}

# Variables for security_group for alb

variable "alb_cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "alb_cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "alb_sg_description" {
  description = "vpc id for security group"
  type        = string
  default     = "Security group for alb usage with ecs"
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running. Defaults to 0."
  type        = number
  #default     = 0
}

################ cantainer_denition ##############

variable "container_name" {
  type        = string
  description = "The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, _ allowed)"
}

variable "container_image" {
  type        = string
  description = "The image used to start the container. Images in the Docker Hub registry available by default"
}

variable "container_memory" {
  type        = number
  description = "The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  default     = null
}

variable "container_cpu" {
  type        = number
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  default     = 0
}

variable "container_memory_reservation" {
  type        = number
  description = "The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  default     = null
}

variable "port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = []
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html
variable "healthcheck" {
  type = object({
    command     = list(string)
    retries     = number
    timeout     = number
    interval    = number
    startPeriod = number
  })
  description = "A map containing command (string), timeout, interval (duration in seconds), retries (1-10, number of times to retry before marking container unhealthy), and startPeriod (0-300, optional grace period to wait, in seconds, before failed healthchecks count toward retries)"
  default     = null
}

variable "essential" {
  type        = bool
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = true
}

variable "entrypoint" {
  type        = list(string)
  description = "The entry point that is passed to the container"
  default     = null
}

variable "working_directory" {
  type        = string
  description = "The working directory to run commands inside the container"
  default     = null
}

variable "container_environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables to pass to the container. This is a list of maps. map_environment overrides environment"
  default     = []
}

variable "extra_hosts" {
  type = list(object({
    ipAddress = string
    hostname  = string
  }))
  description = "A list of hostnames and IP address mappings to append to the /etc/hosts file on the container. This is a list of maps"
  default     = null
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_EnvironmentFile.html
variable "environment_files" {
  type = list(object({
    value = string
    type  = string
  }))
  description = "One or more files containing the environment variables to pass to the container. This maps to the --env-file option to docker run. The file must be hosted in Amazon S3. This option is only available to tasks using the EC2 launch type. This is a list of maps"
  default     = null
}

variable "readonly_root_filesystem" {
  type        = bool
  description = "Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = false
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html
variable "linux_parameters" {
  type = object({
    capabilities = object({
      add  = list(string)
      drop = list(string)
    })
    devices = list(object({
      containerPath = string
      hostPath      = string
      permissions   = list(string)
    }))
    initProcessEnabled = bool
    maxSwap            = number
    sharedMemorySize   = number
    swappiness         = number
    tmpfs = list(object({
      containerPath = string
      mountOptions  = list(string)
      size          = number
    }))
  })
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html"
  default     = null
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_FirelensConfiguration.html
variable "firelens_configuration" {
  type = object({
    type    = string
    options = map(string)
  })
  description = "The FireLens configuration for the container. This is used to specify and configure a log router for container logs. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_FirelensConfiguration.html"
  default     = null
}

variable "mount_points" {
  type = list(object({
    containerPath = string
    sourceVolume  = string
    readOnly      = bool
  }))

  description = "Container mount points. This is a list of maps, where each map should contain `containerPath`, `sourceVolume` and `readOnly`"
  default = [
    {
      "sourceVolume" : "sensor-host-store",
      "containerPath" : "/host-store",
      "readOnly" : false
    }
  ]
}

variable "dns_servers" {
  type        = list(string)
  description = "Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers"
  default     = null
}

variable "dns_search_domains" {
  type        = list(string)
  description = "Container DNS search domains. A list of DNS search domains that are presented to the container"
  default     = null
}

variable "ulimits" {
  type = list(object({
    name      = string
    hardLimit = number
    softLimit = number
  }))
  description = "Container ulimit settings. This is a list of maps, where each map should contain \"name\", \"hardLimit\" and \"softLimit\""
  default     = null
}

variable "volumes_from" {
  type = list(object({
    sourceContainer = string
    readOnly        = bool
  }))
  description = "A list of VolumesFrom maps which contain \"sourceContainer\" (name of the container that has the volumes to mount) and \"readOnly\" (whether the container can write to the volume)"
  default     = []
}

variable "links" {
  type        = list(string)
  description = "List of container names this container can communicate with without port mappings"
  default     = null
}

variable "container_depends_on" {
  type = list(object({
    containerName = string
    condition     = string
  }))
  description = "The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY"
  default     = null
}

variable "docker_labels" {
  type        = map(string)
  description = "The configuration options to send to the `docker_labels`"
  default     = null
}

variable "start_timeout" {
  type        = number
  description = "Time duration (in seconds) to wait before giving up on resolving dependencies for a container"
  default     = null
}

variable "stop_timeout" {
  type        = number
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own"
  default     = null
}

variable "privileged" {
  type        = bool
  description = "When this variable is `true`, the container is given elevated privileges on the host container instance (similar to the root user). This parameter is not supported for Windows containers or tasks using the Fargate launch type."
  default     = false
}

variable "system_controls" {
  type        = list(map(string))
  description = "A list of namespaced kernel parameters to set in the container, mapping to the --sysctl option to docker run. This is a list of maps: { namespace = \"\", value = \"\"}"
  default     = null
}

variable "hostname" {
  type        = string
  description = "The hostname to use for your container."
  default     = null
}

variable "disable_networking" {
  type        = bool
  description = "When this parameter is true, networking is disabled within the container."
  default     = null
}

variable "interactive" {
  type        = bool
  description = "When this parameter is true, this allows you to deploy containerized applications that require stdin or a tty to be allocated."
  default     = null
}

variable "pseudo_terminal" {
  type        = bool
  description = "When this parameter is true, a TTY is allocated. "
  default     = null
}

variable "command" {
  type        = list(string)
  description = "The command that is passed to the container"
  default     = null
}

variable "logDriver" {
  description = "identify the logDriver"
  type        = string
  default     = "awslogs"
}

variable "https_port" {
  description = " https Port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
}

variable "https_protocol" {
  description = "https Protocol to use for routing traffic to the targets"
  type        = string
}


variable "https_type" {
  description = "Type of target that you must specify when registering targets with this target group"
  type        = string
}


variable "account_num_r53" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume"
  default     = "CloudAdmin"
}

variable "custom_domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
}

variable "https_port1" {
  description = " https Port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
}

#ECS Bluegreen Deployment configuration

variable "action_on_timeout" {
  description = "CodeDeploy B/G action to take on timeout"
  type        = string
  default     = "CONTINUE_DEPLOYMENT"
  validation {
    condition     = contains(["CONTINUE_DEPLOYMENT", "STOP_DEPLOYMENT"], var.action_on_timeout)
    error_message = "Valid values are CONTINUE_DEPLOYMENT or STOP_DEPLOYMENT."
  }
}

variable "wait_time_in_minutes" {
  type        = string
  description = "codedeploy b/g Wait time"
  default     = "0"
}

variable "terminate_blue_instances_on_deployment_success_action" {
  type        = string
  description = "action to take on instances in the original environment after a successful blue/green deployment"
  default     = "TERMINATE"
  validation {
    condition     = contains(["TERMINATE", "KEEP_ALIVE"], var.terminate_blue_instances_on_deployment_success_action)
    error_message = "Valid values are TERMINATE or KEEP_ALIVE."
  }
}

variable "terminate_blue_instances_on_deployment_success_termination_wait_time_in_minutes" {
  description = "number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment."
  type        = number
  default     = 5
}

variable "deployment_style_deployment_option" {
  type        = string
  description = "whether to route deployment traffic behind a load balancer"
  default     = "WITH_TRAFFIC_CONTROL"
  validation {
    condition     = contains(["WITH_TRAFFIC_CONTROL", "WITHOUT_TRAFFIC_CONTROL"], var.deployment_style_deployment_option)
    error_message = "Valid values are WITH_TRAFFIC_CONTROL or WITHOUT_TRAFFIC_CONTROL."
  }
}

variable "deployment_style_deployment_type" {
  type        = string
  description = "whether to run an in-place deployment or a blue/green deployment"
  default     = "BLUE_GREEN"
  validation {
    condition     = contains(["BLUE_GREEN", "IN_PLACE"], var.deployment_style_deployment_type)
    error_message = "Valid values are BLUE_GREEN or IN_PLACE."
  }
}

variable "auto_rollback_configuration_enabled" {
  type        = bool
  description = "autorollback whether true or false"
  default     = true
  validation {
    condition     = contains([true, false], var.auto_rollback_configuration_enabled)
    error_message = "Valid values are true or false."
  }
}

variable "auto_rollback_configuration_events" {
  type        = list(string)
  description = "event type or types that trigger a rollback"
  default     = ["DEPLOYMENT_FAILURE"]
  validation {
    condition     = contains(["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"], element(var.auto_rollback_configuration_events, 0))
    error_message = "Valid values are DEPLOYMENT_FAILURE or DEPLOYMENT_STOP_ON_ALARM."
  }
}

variable "deployment_config_name" {
  description = "Enter Application name"
  type        = string
  default     = "CodeDeployDefault.ECSAllAtOnce"
  validation {
    condition     = contains(["CodeDeployDefault.ECSAllAtOnce", "CodeDeployDefault.ECSCanary10Percent5Minutes", "CodeDeployDefault.ECSCanary10Percent15Minutes"], var.deployment_config_name)
    error_message = "Valid values are CodeDeployDefault.ECSAllAtOnce or CodeDeployDefault.ECSCanary10Percent5Minutes or CodeDeployDefault.ECSCanary10Percent15Minutes."
  }
}

variable "codedeploy_app_compute_platform" {
  description = "Enter CodeDeploy computing platform, ECS"
  type        = string
  default     = "ECS"
}

variable "deployment_group_service_role_arn" {
  description = "Enter deloyment group service role ARN for CodeDeploy -> Blue green deployment"
  type        = string
  default     = "arn:aws:iam::750713712981:role/AWSCodeDeployRoleForECS"
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = number
  default     = 90
}


## Variables for ECS Fargate Autoscaling

variable "create_autoscaling" {
  description = "Whether to create autoscaling"
  type        = bool
}

variable "use_target_tracking_scaling" {
  description = "Whether to use target tracking scaling policy or step scaling policy"
  type        = bool
  default     = true
}

variable "step_scaling_policy_configuration" {
  description = "Configuration for step scaling policy"
  type = object({
    adjustment_type         = string
    cooldown                = number
    metric_aggregation_type = string
    step_adjustment = list(object({
      metric_interval_lower_bound = number
      metric_interval_upper_bound = number
      scaling_adjustment          = number
    }))
  })
}


variable "target_tracking_scaling_policy_configuration" {
  description = "Configuration for target tracking scaling policy"
  type = object({
    target_value       = number
    scale_in_cooldown  = number
    scale_out_cooldown = number
    disable_scale_in   = bool
    predefined_metric_specification = list(object({
      predefined_metric_type = string
    }))
  })
}

variable "step_scaling_policy_name" {
  description = "The name of the step scaling policy"
  type        = string
}

variable "secretsmanager_description" {
  description = "Description of the secret"
  type        = string
  default     = "testing of secrets manager with secret string as key value pairs"
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 0
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
  default     = true
}


variable "target_tracking_scaling_policy_name" {
  description = "The name of the target tracking scaling policy"
  type        = string
}

variable "runtime_platform" {
  description = "Configuration block for runtime_platform that containers in your task may use."
  type        = map(string)
}

variable "volumes" {
  description = "A set of volumes blocks that containers in your task may use."
  type = list(object({
    host_path = string
    name      = string
  }))
  default = [
    {
      name      = "sensor-host-store"
      host_path = ""
    }
  ]
}



variable "wiz_secret_credential" {
  type        = string
  description = "The name given in the parameter store for the golden wiz_secret_credential"
}

variable "wiz_repository_Credentials" {
  type        = map(string)
  description = "Container repository credentials; required when using a private repo.  This map currently supports a single key; \"credentialsParameter\", which should be the ARN of a Secrets Manager's secret holding the credentials"
  default     = null
}