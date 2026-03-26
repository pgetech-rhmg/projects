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

variable "email_from" {
  description = "Email address used as sender"
  type        = string
  default     = ""
}

variable "email_identity" {
  description = "SES verified identity for email sending"
  type        = string
  default     = ""
}

variable "enable_push" {
  description = "Enable Push Notifications"
  type        = bool
  default     = false
}

variable "apns_bundle_id" {
  description = "APNS Bundle ID"
  type        = string
  default     = ""
}

variable "apns_team_id" {
  description = "APNS Team ID"
  type        = string
  default     = ""
}

variable "apns_token_key" {
  description = "APNS Token Key"
  type        = string
  default     = ""
}

variable "apns_token_key_id" {
  description = "APNS Token Key ID"
  type        = string
  default     = ""
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