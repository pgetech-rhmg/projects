variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#variables for parameter store paramter_names
variable "ssm_parameter_vpc_id" {
  description = "The value of vpc id stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "The value of subnet id_1 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "Tthe value of subnet id_2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_golden_ami" {
  description = "The name given in parameter store for the golden ami"
  type        = string
}

#variables for the module codedeploy_app_ec2
variable "codedeploy_app_name" {
  description = "The name of the application."
  type        = string
}

#variables for the module deployment_config_ec2
variable "deployment_config_name" {
  description = "The name of the deployment config."
  type        = string
}

variable "minimum_healthy_hosts" {
  description = <<-DOC
    type:
      The type can either be `FLEET_PERCENT` or `HOST_COUNT`.
    value:
      The value when the type is `FLEET_PERCENT` represents the minimum number of healthy instances 
      as a percentage of the total number of instances in the deployment.
      When the type is `HOST_COUNT`, the value represents the minimum number of healthy instances as an absolute value.
  DOC
  type = object({
    type  = string
    value = number
  })
}

#variables for the module deployment_group
variable "deployment_group_name" {
  description = "The name of the deployment group."
  type        = string
}

variable "deployment_option" {
  description = "Indicates whether to route deployment traffic behind a load balancer. Valid Values are WITH_TRAFFIC_CONTROL or WITHOUT_TRAFFIC_CONTROL."
  type        = string
}

variable "ec2_tag_filter_key" {
  description = "The key of the tag filter."
  type        = string
}

variable "ec2_tag_filter_type" {
  description = "The type of the tag filter, either KEY_ONLY, VALUE_ONLY, or KEY_AND_VALUE."
  type        = string
}

variable "ec2_tag_filter_value" {
  description = "The value of the tag filter."
  type        = string
}
#variables of alb 
variable "alb_name" {
  description = "Name of the alb on AWS"
  type        = string
}

variable "alb_s3_bucket_name" {
  description = "Name of the S3 bucket for alb logs."
  type        = string
}

#listener
variable "lb_listener_http" {
  description = "A list of maps describing HTTP listeners for ALB."
  type        = any
}

variable "lb_listener_https" {
  description = "A list of maps describing HTTPS listeners for ALB."
  type        = any
}

variable "certificate_arn" {
  description = "The ARN of the certificate to attach to the listener."
  type        = list(map(string))
}

variable "lb_listener_rule_http" {
  description = "A list of maps describing the HTTP listener rules for ALB."
  type        = any
}

variable "lb_listener_rule_https" {
  description = "A list of maps describing the HTTPS listener rules for ALB."
  type        = any
}

#lb_target_group
variable "lb_target_group_name" {
  description = "Name of the target group. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "lb_target_group_target_type" {
  description = "Type of target that you must specify when registering targets with this target group."
  type        = string
}

variable "lb_target_group_port" {
  description = "Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = number
}

variable "lb_target_group_protocol" {
  description = "Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip or alb."
  type        = string
}

variable "health_check_enabled" {
  description = "Whether health checks are enabled."
  type        = bool
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds."
  type        = number
}

variable "health_check_matcher" {
  description = "Response codes to use when checking for a healthy responses from a target."
  type        = number
}

variable "health_check_path" {
  description = "Destination for the health check request."
  type        = string
}

variable "health_check_port" {
  description = "Port to use to connect with the target. Valid values are either ports 1-65535, or traffic-port."
  type        = string
}

variable "health_check_protocol" {
  description = "Protocol to use to connect with the target."
  type        = string
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response means a failed health check."
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering the target unhealthy."
  type        = number
}

variable "targets_ec2_port" {
  description = "The port on which targets receive traffic."
  type        = number
}

#variables of security group - alb
variable "alb_sg_name" {
  description = "Name of the security group."
  type        = string
}

variable "alb_sg_description" {
  description = "Security group description for example usage with alb."
  type        = string
}

variable "alb_cidr_ingress_rules" {
  description = "Ingress rule for the CIDR network range."
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
  description = "Egress rule for the CIDR network range."
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

#variables of security group - Ec2
variable "ec2_sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "ec2_sg_description" {
  description = "Security group description for example usage with EC2"
  type        = string
}

variable "ec2_cidr_egress_rules" {
  description = "Egress rule for the CIDR network range."
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

#variables of module ec2 
variable "ec2_name" {
  description = "Name to be used on EC2 instance created."
  type        = string
}

variable "ec2_instance_type" {
  description = "Type of the ec2 instance."
  type        = string
}

variable "ec2_az" {
  description = "List of availability zone for ec2."
  type        = string
}

#Iam role
variable "role_name" {
  description = "Name of the iam role."
  type        = string
}

variable "aws_service" {
  description = "Aws service of the iam role."
  type        = list(string)
}

variable "policy_arns" {
  description = "Policy arn for the iam role."
  type        = list(string)
}

#variables for Api vpc_endpoint 
variable "api_service_name" {
  description = "The service name.It creates a VPC endpoint for CodeDeploy API operations."
  type        = string
}

#variables for Agent vpc_endpoint 
variable "agent_service_name" {
  description = "The service name.It creates a VPC endpoint for CodeDeploy agent operations."
  type        = string
}

#variables for security_group_vpc_endpoint
variable "vpc_endpoint_cidr_ingress_rules" {
  description = "Ingress rule for the CIDR network range."
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

variable "vpc_endpoint_cidr_egress_rules" {
  description = "Egress rule for the CIDR network range."
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

variable "vpc_endpoint_sg_name" {
  description = "name of the security group associated with endpoint."
  type        = string
}

variable "vpc_endpoint_sg_description" {
  description = "description for security group associated with endpoint."
  type        = string
}

#variables for Tags
variable "optional_tags" {
  description = "optional_tags."
  type        = map(string)
  default     = {}
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)."
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)."
  type        = string
}

variable "Notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "Owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3."
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud."
  type        = list(string)
}