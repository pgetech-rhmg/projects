variable "topic_name" {
  description = "SNS topic name."
  type        = string
}

variable "display_name" {
  description = "Display name for SMS and email subscriptions."
  type        = string
  default     = ""
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
