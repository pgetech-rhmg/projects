variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}


variable "vpc_id" {
  description = "Identifier of the VPC in which to create your ALB/Target Group and security groups."
  type        = string

  validation {
    condition     = can(regex("^(vpc-).+[a-z0-9]$", var.vpc_id))
    error_message = "Error! Enter a valid vpc id."
  }
}

variable "custom_domain_name" {
  description = "The domain name for which the certificate should be issued."
  type        = string
}

variable "subject_alternative_names" {
  description = "A set of domains the should be SANs in the issued certificate."
  type        = list(string)
  default     = []
}

variable "alb_security_groups" {
  description = "The security groups to assign to the ALB."
  type        = list(string)
}

variable "ec2_security_groups" {
  description = "The security groups to assign to the EC2 instances."
  type        = list(string)
}

variable "allow_overwrite" {
  description = "Allow creation of this record in Terraform to overwrite an existing record."
  type        = bool
  default     = false
}
