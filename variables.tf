############################################
# Core
############################################

variable "app_name" {
  description = "Application name used for naming ALB resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC that the ALB and target group belong to."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach to the ALB."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to attach to the ALB."
  type        = string
}


############################################
# Listener / TLS
############################################

variable "certificate_arn" {
  description = "ARN of the ACM certificate to attach to the HTTPS listener."
  type        = string
}


############################################
# Target Group / EC2
############################################

variable "instance_id" {
  description = "EC2 instance ID to register with the target group."
  type        = string
}

variable "target_port" {
  description = "Port the target EC2 instance listens on."
  type        = number
  default     = 5000
}

variable "health_check_path" {
  description = "HTTP path used for target group health checks."
  type        = string
  default     = "/health"
}


############################################
# Tags
############################################

variable "tags" {
  description = "Common tags."
  type        = map(string)
}