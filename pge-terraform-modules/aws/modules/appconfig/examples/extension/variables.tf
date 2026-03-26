variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "name" {
  description = "A name for the extension. Each extension name in your account must be unique."
  type        = string
}

variable "description" {
  description = "Information about the extension."
  type        = string
}

variable "parameter_name" {
  description = "A name for the parameter."
  type        = string
}

variable "parameter_required" {
  description = "Determines if a parameter value must be specified in the extension association."
  type        = string
}

variable "parameter_description" {
  description = "Information about the parameter."
  type        = string
}

variable "action_point" {
  description = "The point at which to perform the defined actions."
  type        = string
}

variable "action_name" {
  description = "The action name"
  type        = string
}

variable "action_role" {
  description = "The role to assume."
  type        = string
}

variable "action_uri" {
  description = "The extension URI associated to the action point in the extension definition. Can be ARN for Lambda function, SQS queue, SNS topic, or EventBridge default event bus."
  type        = string
}

variable "action_description" {
  description = "Information about the action."
  type        = string
}

variable "enable_extension_association" {
  description = "Specifies if extension association is to be enabled or not."
  type        = bool
  default     = false
}

variable "resource_arn_to_associate_with_extension" {
  description = "The Amazon Resource Name (ARN) of the resource to associate with the AppConfig Extension."
  type        = string
  default     = null
}