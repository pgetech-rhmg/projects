variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

####################################### variables of alb ######################################
variable "alb_name" {
  description = "Name of the alb on AWS"
  type        = string
}

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
  description = "A list of maps describing the listener rules for ALB."
  type        = any
}

variable "lb_listener_rule_https" {
  description = "A list of maps describing the listener rules for ALB."
  type        = any
}

####################################### variables of s3 ######################################
variable "bucket_name" {
  description = "Name of the s3 bucket to store alb logs on AWS"
  type        = string
}

variable "policy" {
  description = "Policy template file in json format "
  type        = string
  default     = "s3_policy.json"
}

####################################### variables of security group ######################################
variable "alb_sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "alb_sg_description" {
  description = "Security group for example usage with alb"
  type        = string
}

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

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "sg_description" {
  description = "Security group for example usage with EC2"
  type        = string
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

####################################### variables of ec2 ######################################

variable "ec2_name" {
  type        = string
  description = "Name to be used on EC2 instance created"
}

variable "ec2_instance_type" {
  type        = string
  description = "type of the ec2 instance"
}

variable "ec2_az" {
  type        = string
  description = "List of availability zone for ec2"
}

####################################### variables of tags ######################################

variable "Optional_tags" {
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
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}