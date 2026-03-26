variable "package_name" {
  description = "Unique name for the package"
  type        = string
}

variable "package_description" {
  description = "Description of the package"
  type        = string
  default     = null
}

variable "s3_bucket_name" {
  description = "Specifies whether a welcome email is sent to a user after the user is created in the user pool."
  type        = string
}

variable "s3_key" {
  description = "Key (file name) of the package"
  type        = string
}

variable "package_type" {
  description = "The type of package"
  type        = string
  default     = "TXT-DICTIONARY"
}