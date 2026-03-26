variable "aws_region" {
  type        = string
  description = "AWS Region"
}

# Variables for assume_role used in terraform.tf

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  description = "AWS role"
  type        = string
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
  #default     = "/vpc/privatesubnet4/id"
  default = "/vpc/managementsubnet1/id"
}

variable "parameter_subnet_id2_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  #default     = "/vpc/privatesubnet5/id"
  default = "/vpc/managementsubnet2/id"
}

variable "parameter_subnet_cidr1_id" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  #default     = "/vpc/privatesubnet1/cidr"
  default = "/vpc/managementsubnet1/cidr"
}

variable "parameter_subnet_cidr2_id" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  #default     = "/vpc/privatesubnet2/cidr"
  default = "/vpc/managementsubnet2/cidr"
}

variable "parameter_subnet_cidr3_id" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = "/vpc/privatesubnet3/cidr"
}

variable "parameter_alb_cidr_id1" {
  type        = string
  description = "alb cidr block stored in aws_ssm_parameter"
  default     = "/vpc/securitygroup/inbound/pgecidr1"
}

variable "parameter_alb_cidr_id2" {
  type        = string
  description = "alb cidr block stored in aws_ssm_parameter"
  default     = "/vpc/securitygroup/inbound/pgecidr2"
}

variable "parameter_alb_cidr_id3" {
  type        = string
  description = "alb cidr block stored in aws_ssm_parameter"
  default     = "/vpc/securitygroup/inbound/pgecidr3"
}

variable "jfrog_credentials" {
  type        = string
  description = "Jfrog Credentials stored in the secrets"
  default     = "/jfrog/credentials"
}

variable "parameter_golden_ami_name" {
  type        = string
  description = "The name given in the parameter store for the golden ami"
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

# Variables for ecs ec2

variable "cluster_name" {
  description = "Enter the name of the cluster"
  type        = string
}

variable "setting_value" {
  description = "The value to assign to the setting. Value values are enabled and disabled."
  type        = string
}

# Variables for ecs capacity provider

variable "ecs_capacity_provider_name" {
  description = "Name of the first capacity provider."
  type        = string
}

# Variables for ecs task definition

variable "requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = list(string)
  default     = ["EC2"]
}

variable "memory" {
  description = "Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
}


# Variables for ecs service

variable "ecs_service_launch_type" {
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2."
  type        = string
  default     = "EC2"
}

variable "deployment_type" {
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS, EXTERNAL. Default: ECS."
  type        = string
  default     = "ECS"
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

variable "ecs_sg_description" {
  description = "Security group for example usage with ecs"
  type        = string
  default     = "Security group for example usage with ecs"
}

# Variables for IAM role of ecs

variable "ecs_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "ecs_iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
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

variable "target_group_target_type" {
  description = "Type of target that you must specify when registering targets with this target group"
  type        = string
  default     = "ip"
}

variable "target_group_port" {
  description = " Port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}
variable "target_group_healthcheck" {
  description = "ALB target group Healthcheck."
  type        = any
  default = [{
    enabled             = true
    interval            = 10
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 9
    unhealthy_threshold = 10
  }]
}

variable "target_group_stickiness" {
  description = "ALB target group stickiness"
  type        = any
  default = [{
    cookie_duration = 86400
    enabled         = true
    type            = "lb_cookie"
  }]
}


# Variables for s3

variable "policy" {
  description = "Policy template file in json format "
  type        = string
}

# Variables for security_group for alb

variable "alb_sg_description" {
  description = "ECS-EC2 ALB security group"
  type        = string
  default     = "ECS-EC2 ALB security group"
}


# Variable for cloudwatch

variable "log_group_name_prefix" {
  type        = string
  description = "To identify the log group name"
}

# Variables for autoscaling group

variable "from_port" {
  description = "from_port"
  type        = number
  default     = 0
}
variable "to_port" {
  description = "to_port"
  type        = number
  default     = 65535
}
variable "asg_max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
}

variable "asg_min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
}

variable "asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
}

variable "instance_type" {
  description = "Override the instance type in the Launch Template."
  type        = string
}

variable "autoscaling_policy_name" {
  description = "The name of the Policy."
  type        = string
  default     = "asg_policy"
}

variable "scaling_adjustment" {
  description = "The number of instances by which to scale. adjustment_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity."
  type        = number
}

variable "adjustment_type" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity."
  type        = string
  default     = "ChangeInCapacity"
}

variable "launch_template_name" {
  description = "Name of the launch template."
  type        = string
  default     = ""
}


# Variables for target group of asg


variable "port" {
  description = "Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = number
}

variable "protocol" {
  description = "Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = string
  default     = "HTTP"
}

# Container_definition variables 

variable "container_name" {
  type        = string
  description = "The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, _ allowed)"
}

variable "fluentbit_container_name" {
  type        = string
  description = "The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, _ allowed)"
}

variable "container_image" {
  type        = string
  description = "The image used to start the container. Images in the Docker Hub registry available by default"
}

variable "fluentbit_container_image" {
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

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running. Defaults to 0."
  type        = number
}

variable "container_memory_reservation" {
  type        = number
  description = "The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  default     = 100
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
variable "fluentbit_port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = []
}

variable "interactive" {
  type        = bool
  description = "When this parameter is true, this allows you to deploy containerized applications that require stdin or a tty to be allocated."
  default     = null
}
variable "entrypoint" {
  type        = list(string)
  description = "The entry point that is passed to the container"
  default     = null
}
variable "fluentbit_entrypoint" {
  type        = list(string)
  description = "The entry point that is passed to the container"
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
  default     = "awsfirelens"
}

variable "fluentbit_logDriver" {
  description = "identify the logDriver"
  type        = string
  default     = "awslogs"
}

variable "fluentbit_awslogs_group" {
  description = "identify the awslogs_region "
  type        = string
  default     = "firelens-container"
}

variable "fluentbit_awslogs_region" {
  description = "identify the awslogs_region "
  type        = string
  default     = "us-west-2"
}

variable "fluentbit_awslogs_stream_prefix" {
  description = "identify the awslogs_stream_prefix "
  type        = string
  default     = "firelens"
}

variable "fluentbit_container_memory_reservation" {
  type        = number
  description = "The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  default     = 50
}

variable "essential" {
  type        = bool
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = true
}

variable "fluentbit_essential" {
  type        = bool
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = true
}

variable "readonly_root_filesystem" {
  type        = bool
  description = "Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = false
}

variable "custom_domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
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
variable "privileged" {
  type        = bool
  description = "When this variable is `true`, the container is given elevated privileges on the host container instance (similar to the root user). This parameter is not supported for Windows containers or tasks using the Fargate launch type."
  default     = null
}
variable "hostname" {
  type        = string
  description = "The hostname to use for your container."
  default     = null
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

############################


variable "lb_listener_https_port" {
  description = " https Port on which targets receive traffic, unless overridden when registering a specific target"
  type        = number
}

############### secret manager variables #########

variable "secretsmanager_description" {
  description = "Description of the secret"
  type        = string
  default     = "ECS-EC2 of secrets manager with secret string as key value pairs"
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

########## template file variables ######

variable "template_file_name" {
  description = "Policy template file in json format "
  type        = string
  default     = "kms_user_policy.json"
}

variable "kms_description_for_secretsmanager" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}


############security group variables #######
variable "http_port" {
  description = "port for application"
  type        = number
}

variable "https_port" {
  description = "port for application"
  type        = number
}

variable "sample_application_port1" {
  description = "port for application"
  type        = number
}


variable "sns_topic_cloudwatch_alarm_arn" {
  description = "Enter the sns_topic_cloudwatch_alarm_arn to send alerts to"
  type        = string
}
