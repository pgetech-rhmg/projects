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

variable "solution_stack" {
  type        = string
  description = "Elastic Beanstalk solution stack regex"
}

############################################
# Health
############################################

variable "health_check_path" {
  description = "ALB health check path. Use something that returns 200 without auth."
  type        = string
  default     = "/"
}

############################################
# Secrets Manager
############################################

variable "secrets_manager_arn" {
  description = "ARN of the JSON secret"
  type        = string
  default     = null
  nullable    = true
}

############################################
# Environment Variables
############################################

variable "environment_variables" {
  description = "Environment variables for application"
  type        = map(string)
  default     = {}
}

############################################
# Artifact
############################################

variable "artifact" {
  description = "S3 artifact information"
  type = object({
    bucket = string
    key    = string
  })
}

############################################
# Networking
############################################

variable "network" {
  description = "VPC + subnet configuration"
  type = object({
    vpc_id          = string
    private_subnets = list(string)
    alb_subnets     = list(string)
  })
}

############################################
# Security
############################################

variable "security" {
  description = "Security configuration"
  type = object({
    public          = bool
    certificate_arn = optional(string)
  })

  default = {
    public          = false
    certificate_arn = null
  }
}

############################################
# Scaling
############################################

variable "scaling" {
  description = "Scaling configuration"
  type = object({
    min_size      = optional(number)
    max_size      = optional(number)
    instance_type = optional(string)
  })

  default = {}
}

############################################
# Tags
############################################

variable "tags" {
  type    = map(string)
  default = {}
}
