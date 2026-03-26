variable "aws_region" {
  description = "AWS Region"
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

variable "service_name" {
  type        = string
  description = "The service name.For AWS services the service name is usually in the form com.amazonaws.<region>.<service>.The SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook"
  default     = null
}


variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
  default = {
    Name = "CloudCOE-vpc-endpoint"
  }
}

variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "sg_name" {
  description = "name of the security group"
  type        = string
}

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
  default = []
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
  default = []
}

