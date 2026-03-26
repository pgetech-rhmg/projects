variable "app_name" {
  description = "Name of the Pinpoint application"
  type        = string
}

variable "enable_sms" {
  description = "Enable SMS channel"
  type        = bool
  default     = false
}

variable "enable_email" {
  description = "Enable Email channel"
  type        = bool
  default     = false
}

variable "enable_push" {
  description = "Enable Push Notifications"
  type        = bool
  default     = false
}

variable "account_num" {
  # Predefined in TFC
  type        = string
  description = "Target AWS account number - predefined in TFC"
}

variable "aws_role" {
  # Predefined in TFC
  description = "AWS role to assume - predefined in TFC"
  type        = string
}