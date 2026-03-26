variable "name" {
  description = "The name of the app."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,100}$", var.name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "app_type" {
  description = "The type of app. Valid values are JupyterServer, KernelGateway and TensorBoard."
  type        = string
  validation {
    condition     = contains(["JupyterServer", "KernelGateway", "TensorBoard"], var.app_type)
    error_message = "Error! values for 'app_type' should be 'JupyterServer, KernelGateway and TensorBoard'."
  }
}

variable "domain_id" {
  description = "The domain ID."
  type        = string
}

variable "user_profile_name" {
  description = "The user profile name."
  type        = string
}

variable "instance_type" {
  description = "The instance type that the image version runs on. For valid values see 'https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-instance-types.html'."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^(ml.t3*|ml.m5*|ml.c5*|ml.r5*|ml.p3*|ml.g5*|ml.g4dn*)", var.instance_type)) || var.instance_type == null
    error_message = "Invalid instance type. Check the description for valid values."
  }
}

variable "lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:studio-lifecycle-config/([a-zA-Z0-9])+(.*)$", var.lifecycle_config_arn)) || var.lifecycle_config_arn == null
    error_message = "The lifecycle_config_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:studio-lifecycle-config/<lifecycle_config_arn_name>."
  }
}

variable "sagemaker_image_arn" {
  description = "The ARN of the SageMaker image that the image version belongs to."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:image/([a-zA-Z0-9])+(.*)$", var.sagemaker_image_arn)) || var.sagemaker_image_arn == null
    error_message = "The sagemaker_image_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:image/<image_name>."
  }
}

variable "sagemaker_image_version_arn" {
  description = "The ARN of the image version created on the instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:image-version/([a-zA-Z0-9])+(.*)$", var.sagemaker_image_version_arn)) || var.sagemaker_image_version_arn == null
    error_message = "The sagemaker_image_version_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:image/<image_name>/<version>."
  }
}

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}