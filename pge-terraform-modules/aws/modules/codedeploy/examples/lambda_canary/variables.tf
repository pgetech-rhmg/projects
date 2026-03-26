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

#variables for the module codedeploy_app_lambda
variable "codedeploy_app_name" {
  description = "The name of the application."
  type        = string
}

variable "codedeploy_app_compute_platform" {
  description = "The compute platform can either be ECS, Lambda, or Server"
  type        = string
}

#variables for the module deployment_config_lambda
variable "deployment_config_name" {
  description = "The name of the deployment config."
  type        = string
}

variable "deployment_config_compute_platform" {
  description = "The compute platform can either be ECS, Lambda, or Server."
  type        = string
}

variable "traffic_routing_config" {
  description = <<-DOC
    type:
      Type of traffic routing config. One of `TimeBasedCanary`, `TimeBasedLinear`, `AllAtOnce`.
    interval:
      The number of minutes between the first and second traffic shifts of a deployment.
    percentage:
      The percentage of traffic to shift in the first increment of a deployment.
  DOC
  type = object({
    type       = string
    interval   = number
    percentage = number
  })
}

#variables for the module deployment_group
variable "deployment_group_name" {
  description = "The name of the deployment group."
  type        = string
}

variable "deployment_type" {
  description = "Indicates whether to run an in-place deployment or a blue/green deployment."
  type        = string
}

variable "deployment_option" {
  description = "Indicates whether to route deployment traffic behind a load balancer. "
  type        = string
}

#Iam role
variable "role_name" {
  description = "Name of the iam role"
  type        = string
}

variable "aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

#variables for Api vpc_endpoint 
variable "api_service_name" {
  description = "The service name.It creates a VPC endpoint for CodeDeploy API operations."
  type        = string
}

#variables for security_group_vpc_endpoint
variable "vpc_endpoint_cidr_ingress_rules" {
  description = "Ingress rule for the CIDR network range"
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
  description = "Egress rule for the CIDR network range"
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
  description = "name of the security group associated with endpoint"
  type        = string
}

variable "vpc_endpoint_sg_description" {
  description = "description for security group associated with endpoint"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

#variables for Tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
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