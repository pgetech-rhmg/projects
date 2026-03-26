variable "aws_region" {
  type        = string
  description = "AWS region"
}

# Variables for assume_role used in terraform.tf

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "wiz_container_name" {
  type        = string
  description = "twistlock container name"
}

variable "wiz_container_image" {
  type        = string
  description = "twistlock container image"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

# Variables for aws_ssm_parameter

variable "parameter_vpc_id_name" {
  type        = string
  description = "Id of vpc stored in aws_ssm_parameter"
}

variable "parameter_subnet_id1_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
}

variable "parameter_subnet_id2_name" {
  type        = string
  description = "Name of the subnet id stored in aws_ssm_parameter"
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

# Variables for ecs_fargate

variable "cluster_name" {
  description = "Enter the name of the cluster"
  type        = string
}

variable "setting_value" {
  description = "The value to assign to the setting. Value values are enabled and disabled."
  type        = string
}

variable "ecs_cluster_capacity_providers" {
  description = "Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  type        = list(string)
}

variable "ecs_default_cluster_capacity_provider" {
  description = "The short name of the capacity provider."
  type        = string
}

# Variables for ecs task definition

variable "family_service" {
  description = "A unique name for your task definition."
  type        = string
}

variable "requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = list(string)
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

# Variables for ecs account setting default

variable "ecs_account_name" {
  description = "Name of the account setting to set. Valid values are serviceLongArnFormat, taskLongArnFormat, containerInstanceLongArnFormat, awsvpcTrunking and containerInsights."
  type        = string
}

variable "ecs_account_setting_value" {
  description = "State of the setting. Valid values are enabled and disabled."
  type        = string
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

variable "ecs_sg_name" {
  description = "name of the security group"
  type        = string
}

variable "ecs_sg_description" {
  description = "vpc id for security group"
  type        = string
}

# Variables for IAM role of ecs

variable "ecs_iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "ecs_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "ecs_iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

# Variable for load balancer

variable "alb_name" {
  description = "The resource name and Name tag of the load balancer."
  type        = string
}

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

variable "alb_s3_bucket_name" {
  description = "Name of the S3 bucket for alb logs."
  type        = string
}

variable "policy" {
  description = "Policy template file in json format "
  type        = string
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

variable "alb_sg_name" {
  description = "name of the security group"
  type        = string
}

variable "alb_sg_description" {
  description = "vpc id for security group"
  type        = string
}

# Variables for security_group for vpc endpoint

variable "cidr_ingress_rules" {
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

variable "cidr_egress_rules" {
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

variable "sg_name" {
  description = "name of the security group"
  type        = string
}

variable "sg_description" {
  description = "vpc id for security group"
  type        = string
}

# Variable for cloudwatch

variable "log_group_name_prefix" {
  type        = string
  description = "To identify the log group name"
}

########## template file variables ######

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

variable "essential" {
  type        = bool
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value"
  default     = true
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
}

variable "awslogs_region" {
  description = "identify the awslogs_region "
  type        = string
}

variable "awslogs_group" {
  description = "identify the awslogs_region "
  type        = string
}

variable "awslogs_stream_prefix" {
  description = "identify the awslogs_stream_prefix "
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the certificate to attach to the listener."
  type        = list(map(string))
}

variable "lb_listener_https" {
  description = "A list of maps describing HTTPS listeners for ALB."
  type        = any
}

#ECS Bluegreen Deployment configuration

variable "action_on_timeout" {
  description = "CodeDeploy B/G action to take on timeout"
  type        = string
}

variable "wait_time_in_minutes" {
  type        = string
  description = "codedeploy b/g Wait time"
}

variable "action" {
  type        = string
  description = "action to proceed for the codedeploy"
}

variable "termination_wait_time_in_minutes" {
  description = "wait time to terminate the task for codedeploy failure"
  type        = number
}

variable "deployment_option" {
  type        = string
  description = "deployment option for codedeploy"
}

variable "codedeploy_deployment_type" {
  type        = string
  description = "codedeploy deployment type"
}

variable "auto_rollback_configuration_enabled" {
  type        = bool
  description = "autorollback whether true or false"
}

variable "auto_rollback_configuration_events" {
  type        = list(string)
  description = "auto_rollback_configuration_events"
}

variable "deployment_config_name" {
  description = "Enter Application name"
  type        = string
  default     = "CodeDeployDefault.ECSAllAtOnce"
}

variable "codedeploy_application_name" {
  description = "Enter Application name"
  type        = string
}

variable "codedeploy_deployment_groupname" {
  description = "Enter application deployment group name"
  type        = string
}
variable "codedeploy_app_compute_platform" {
  description = "Enter CodeDeploy computing platform, ECS"
  type        = string
}

variable "deployment_group_service_role_arn" {
  description = "Enter deloyment group service role ARN for CodeDeploy -> Blue green deployment"
  type        = string
}

variable "jfrog_credentials" {
  type        = string
  description = "Jfrog Credentials stored in the secrets"
  default     = "/jfrog/credentials"
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
