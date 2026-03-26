#variables for image version

variable "image_name" {
  description = "The name of the image. Must be unique to your account."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,62}$", var.image_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, - (hyphen)."
  }
}

variable "base_image" {
  description = "The registry path of the container image on which this image version is based."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]*.dkr.ecr.([a-zA-Z0-9][a-zA-Z0-9-_]*).amazonaws.com/[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,62}:[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,62}$", var.base_image))
    error_message = "The sagemaker_image_version_arn is required and the allowed format is aws account.dkr.ecr.region.amazonaws.com/repo_name:container-image-tag."
  }
}