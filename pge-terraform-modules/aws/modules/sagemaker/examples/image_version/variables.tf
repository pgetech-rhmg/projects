# variables for provider
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#variables for image version
variable "image_name" {
  description = "The name of the image. Must be unique to your account."
  type        = string
}

variable "base_image" {
  description = "The registry path of the container image on which this image version is based."
  type        = string
}