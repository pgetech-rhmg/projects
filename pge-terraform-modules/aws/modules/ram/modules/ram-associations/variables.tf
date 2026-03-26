variable "principal_ids" {
  description = "List of Principal Id's to be associated with Ram Share"
  type        = list(string)
  default     = []
}

variable "resource_share_arn" {
  description = "RAM share ARNs"
  type        = string
  default     = ""
}

variable "resource_arns" {
  description = "Resource arn"
  type        = list(string)
  default     = []

}
