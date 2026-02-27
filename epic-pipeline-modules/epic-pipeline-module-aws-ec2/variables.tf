############################################
# Core
############################################

variable "app_name" {
  type        = string
  description = "Elastic Beanstalk environment name"
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

############################################
# AMI
############################################

variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "network" {
  description = "Network configuration"
  type = object({
    subnet_id          = string
    security_group_ids = list(string)
  })
}

variable "iam" {
  description = "IAM configuration"
  type = object({
    create_instance_profile = bool
    role_name               = optional(string)
    policy_arns             = optional(list(string), [])
  })

  default = {
    create_instance_profile = true
    role_name               = null
    policy_arns             = []
  }
}

variable "root_volume" {
  description = "Root volume configuration"
  type = object({
    size        = number
    type        = string
    kms_key_id  = optional(string)
  })
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

############################################
# Tags
############################################

variable "tags" {
  type    = map(string)
  default = {}
}
