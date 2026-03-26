variable "aws_account" {
  type        = string
  description = "Aws account name, dev, qa, test, production. "
}

variable "aws_role" {
  type = string
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "branch" {
  type = string
}

variable "name" {
  type        = string
  description = "The name of the API Gateway you're deploying"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "lambda_name" {
  type        = string
  description = "The name of your Lambda function"
}

variable "api_gw_resource_policy" {
  type        = string
  description = "The api gw policy"
  default     = "{}"
}

variable "binary_media_types" {
  type        = list(any)
  description = "List of binary media types supported by the REST API."
  default     = []
}

variable "deployment_triggers" {
  type        = list(any)
  description = "List of triggers for this deployment. Values of this list are used in hash function that triggers redeployment when changed."
  default     = []
}

variable "tracing_enabled" {
  type        = bool
  description = "Enable xray tracing"
  default     = true
}

variable "filter_pattern" {
  type        = string
  description = "The filter pattern for log pattern matching"
  default     = ""
}

variable "tags" {
  description = "A map of tags to populate on the trigger resources."
  type        = map(string)
}
