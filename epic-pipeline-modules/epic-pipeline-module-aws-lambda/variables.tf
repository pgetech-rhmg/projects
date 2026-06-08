variable "function_name" {
  description = "Lambda function name."
  type        = string
}

variable "description" {
  description = "Lambda function description."
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Lambda runtime (e.g., nodejs24.x)."
  type        = string
  default     = "nodejs22.x"
}

variable "handler" {
  description = "Lambda handler (e.g., handler.handler)."
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket containing the deployment package."
  type        = string
}

variable "s3_key" {
  description = "S3 object key for the deployment package."
  type        = string
}

variable "memory_size" {
  description = "Memory allocation in MB."
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Function timeout in seconds."
  type        = number
  default     = 30
}

variable "environment_variables" {
  description = "Environment variables for the function."
  type        = map(string)
  default     = {}
}

variable "layers" {
  description = "List of Lambda layer ARNs."
  type        = list(string)
  default     = []
}

variable "vpc_config" {
  description = "VPC configuration for the function."
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrency (set to -1 for unreserved)."
  type        = number
  default     = -1
}

variable "additional_policy_arns" {
  description = "Additional IAM policy ARNs to attach to the execution role."
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Inline IAM policy JSON for the execution role."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days."
  type        = number
  default     = 30
}

variable "tracing_mode" {
  description = "X-Ray tracing mode (Active or PassThrough)."
  type        = string
  default     = "PassThrough"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
