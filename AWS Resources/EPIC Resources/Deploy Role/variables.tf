###############################################################################
# Variables
###############################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "epic_service_role_arn" {
  description = "ARN of the EPIC service role in the EPIC account that will assume this role"
  type        = string
}
