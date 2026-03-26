
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
  default     = "/vpc/privatesubnet4/id"
}

variable "parameter_subnet_id2_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = "/vpc/privatesubnet5/id"
}

variable "parameter_subnet_id3_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = "/vpc/privatesubnet6/id"
}

variable "parameter_subnet_cidr1_id" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = "/vpc/privatesubnet1/cidr"
}

variable "parameter_subnet_cidr2_id" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
  default     = "/vpc/privatesubnet2/cidr"
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
variable "entrypoint" {
  type        = list(string)
  description = "The entry point that is passed to the container"
  default = [
    "fargate",
    "entrypoint",
    "java",
    "-jar",
    "/spring-petclinic/spring-petclinic.jar",
    "--server.port=8081"
  ]
}

variable "runtime_platform" {
  description = "Configuration block for runtime_platform that containers in your task may use."
  type        = map(string)
}


# Variables for ecs service

variable "ecs_service_launch_type" {
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2."
  type        = string
  default     = "FARGATE"
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
  description = "vpc id for security group"
  type        = string
  default     = "Security group for example usage with ecs"
}

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

# Variables for s3

variable "policy" {
  description = "Policy template file in json format "
  type        = string
  default     = "s3_policy.json"
}

# Variables for security_group for alb

variable "alb_sg_description" {
  description = "vpc id for security group"
  type        = string
  default     = "Security group for example usage with ecs"
}

############### sm var #########

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

variable "kms_description_for_secretsmanager" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
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

########## template file variables ######

variable "template_file_name" {
  description = "Policy template file in json format "
  type        = string
  default     = "kms_user_policy.json"
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running. Defaults to 0."
  type        = number
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
}

variable "container_cpu" {
  type        = number
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
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



variable "essential" {
  type        = bool
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = true
}


variable "app_container_environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables to pass to the container. This is a list of maps. map_environment overrides environment"
  default = [
    {
      "name" : "TW_IMAGE_NAME",
      "value" : "tekyantra-np-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:latest"
    },
    {
      "name" : "TW_CONTAINER_NAME",
      "value" : "spring-petclinic"
    },
    {
      "name" : "DEFENDER_TYPE",
      "value" : "fargate"
    },
    {
      "name" : "FARGATE_TASK",
      "value" : "ecs-fargate-twl-ecs-task-definition"
    },
    {
      "name" : "FILESYSTEM_MONITORING",
      "value" : "false"
    }
  ]
}

variable "extra_hosts" {
  type = list(object({
    ipAddress = string
    hostname  = string
  }))
  description = "A list of hostnames and IP address mappings to append to the /etc/hosts file on the container. This is a list of maps"
  default     = null
}

variable "readonly_root_filesystem" {
  type        = bool
  description = "Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = false
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
variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = number
  default     = 90
}

variable "jfrog_credential" {
  type        = string
  description = "jfrog_credential stored in secret manager"
}


variable "service_name" {
  description = "ECS service name"
  type        = string
}
variable "https_protocol" {
  description = "https Protocol to use for routing traffic to the targets"
  type        = string
}
variable "https_type" {
  description = "Type of target that you must specify when registering targets with this target group"
  type        = string
}

variable "custom_domain_name" {
  description = "A domain name for which the certificate should be issued"
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

variable "wiz_secret_credential" {
  type        = string
  description = "The name given in the parameter store for the golden wiz_secret_credential"
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