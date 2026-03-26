variable "user_profile_name" {
  description = "The name for the User Profile."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,62}$", var.user_profile_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, - (hyphen)."
  }
}

variable "domain_id" {
  description = "The ID of the associated Domain."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^d-\\w+", var.domain_id))
    ])
    error_message = "domain_id is required and the allowed format is 'd-#####"
  }
}

variable "execution_role" {
  description = "The execution role ARN for the user."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.execution_role))
    ])
    error_message = "execution_role arn is required and the allowed format is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

variable "security_groups" {
  description = "The security groups to be associated with the user profile."
  type        = list(string)
  validation {
    condition     = alltrue([for i in var.security_groups : can(regex("^sg-\\w+", i))])
    error_message = "Error! Provide list of security_group_ids, value should be in form of 'sg-xxxxxxxx'!"
  }
}

variable "notebook_output_option" {
  description = "Whether to include the notebook cell output when sharing the notebook. The default is Disabled. Valid values are Allowed and Disabled."
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Allowed", "Disabled"], var.notebook_output_option)
    error_message = "Valid values for 'notebook_output_option' are Allowed and Disabled."
  }
}

variable "s3_kms_key_id" {
  description = "When notebook_output_option is Allowed, the AWS Key Management Service (KMS) encryption key ID used to encrypt the notebook cell output in the Amazon S3 bucket."
  type        = string
  validation {
    condition     = var.s3_kms_key_id == null ? true : can(regex("^arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.s3_kms_key_id))
    error_message = "s3_kms_key_id arn is required and the allowed format is arn:aws:kms:<region>:<account-id>:key/<key_id>."
  }
}

variable "s3_output_path" {
  description = "When notebook_output_option is Allowed, the Amazon S3 bucket used to save the notebook cell output."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      can(regex("^s3://([^/]+)/?(.*)$", var.s3_output_path))
    ])
    error_message = "s3_output_path is required and the allowed format is 's3://<bucket_name>/<folder_name>."
  }
}

variable "tensor_board_app_settings_instance_type" {
  description = "The instance type that the image version runs on.For valid values see SageMaker Instance Types."
  type        = string
  validation {
    condition     = can(regex("^(ml.t3*|ml.m5*|ml.c5*|ml.r5*|ml.p3*|ml.g5*|ml.g4dn*|system)", var.tensor_board_app_settings_instance_type))
    error_message = "Valid values for instance_type are 'https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-instance-types.html'."
  }
}

variable "tensor_board_app_settings_lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:studio-lifecycle-config/([a-zA-Z0-9])+(.*)$", var.tensor_board_app_settings_lifecycle_config_arn)) || var.tensor_board_app_settings_lifecycle_config_arn == null
    error_message = "The lifecycle_config_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:studio-lifecycle-config/<lifecycle_config_arn_name>."
  }
}

variable "tensor_board_app_settings_sagemaker_image_arn" {
  description = "The ARN of the SageMaker image that the image version belongs to."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:image/([a-zA-Z0-9])+(.*)$", var.tensor_board_app_settings_sagemaker_image_arn)) || var.tensor_board_app_settings_sagemaker_image_arn == null
    error_message = "The sagemaker_image_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:image/<image_name>."
  }
}

variable "tensor_board_app_settings_sagemaker_image_version_arn" {
  description = "The ARN of the image version created on the instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:image-version/([a-zA-Z0-9])+(.*)$", var.tensor_board_app_settings_sagemaker_image_version_arn)) || var.tensor_board_app_settings_sagemaker_image_version_arn == null
    error_message = "The sagemaker_image_version_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:image/<image_name>/<version>."
  }
}

variable "jupyter_server_app_settings_instance_type" {
  description = "The instance type that the image version runs on.For valid values see SageMaker Instance Types."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^(ml.t3*|ml.m5*|ml.c5*|ml.r5*|ml.p3*|ml.g5*|ml.g4dn*|system)", var.jupyter_server_app_settings_instance_type)) || var.jupyter_server_app_settings_instance_type == null
    error_message = "Valid values for instance_type are 'https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-instance-types.html'."
  }
}

variable "jupyter_server_app_settings_lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:studio-lifecycle-config/([a-zA-Z0-9])+(.*)$", var.jupyter_server_app_settings_lifecycle_config_arn)) || var.jupyter_server_app_settings_lifecycle_config_arn == null
    error_message = "The lifecycle_config_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:studio-lifecycle-config/<lifecycle_config_arn_name>."
  }
}

variable "jupyter_server_app_settings_sagemaker_image_arn" {
  description = "The ARN of the SageMaker image that the image version belongs to."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:image/([a-zA-Z0-9])+(.*)$", var.jupyter_server_app_settings_sagemaker_image_arn)) || var.jupyter_server_app_settings_sagemaker_image_arn == null
    error_message = "The sagemaker_image_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:image/<image_name>."
  }
}

variable "jupyter_server_app_settings_sagemaker_image_version_arn" {
  description = "The ARN of the image version created on the instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:image-version/([a-zA-Z0-9])+(.*)$", var.jupyter_server_app_settings_sagemaker_image_version_arn)) || var.jupyter_server_app_settings_sagemaker_image_version_arn == null
    error_message = "The sagemaker_image_version_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:image/<image_name>/<version>."
  }
}

variable "jupyter_server_app_settings_lifecycle_config_arns" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configurations."
  type        = list(string)
  default     = null
  validation {
    condition     = (var.jupyter_server_app_settings_lifecycle_config_arns == null ? true : (alltrue([for i in var.jupyter_server_app_settings_lifecycle_config_arns : can(regex("^arn:aws:sagemaker:\\w+", i))])))
    error_message = "The lifecycle_config_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:studio-lifecycle-config/<lifecycle_config_arn_name>."
  }
}

variable "kernel_gateway_app_settings_instance_type" {
  description = "The instance type that the image version runs on.For valid values see SageMaker Instance Types."
  type        = string
  validation {
    condition     = can(regex("^(ml.t3*|ml.m5*|ml.c5*|ml.r5*|ml.p3*|ml.g5*|ml.g4dn*|system)", var.kernel_gateway_app_settings_instance_type))
    error_message = "Valid values for instance_type are 'https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-instance-types.html'."
  }
}

variable "kernel_gateway_app_settings_lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:studio-lifecycle-config/([a-zA-Z0-9])+(.*)$", var.kernel_gateway_app_settings_lifecycle_config_arn)) || var.kernel_gateway_app_settings_lifecycle_config_arn == null
    error_message = "The lifecycle_config_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:studio-lifecycle-config/<lifecycle_config_arn_name>."
  }
}

variable "kernel_gateway_app_settings_sagemaker_image_arn" {
  description = "The ARN of the SageMaker image that the image version belongs to."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:image/([a-zA-Z0-9])+(.*)$", var.kernel_gateway_app_settings_sagemaker_image_arn)) || var.kernel_gateway_app_settings_sagemaker_image_arn == null
    error_message = "The sagemaker_image_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:image/<image_name>."
  }
}

variable "kernel_gateway_app_settings_sagemaker_image_version_arn" {
  description = "The ARN of the image version created on the instance."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:sagemaker:\\w+(?:-\\w+)+:[[:digit:]]{12}:image-version/([a-zA-Z0-9])+(.*)$", var.kernel_gateway_app_settings_sagemaker_image_version_arn)) || var.kernel_gateway_app_settings_sagemaker_image_version_arn == null
    error_message = "The sagemaker_image_version_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:image/<image_name>/<version>."
  }
}

variable "kernel_gateway_app_settings_lifecycle_config_arns" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configurations."
  type        = list(string)
  default     = null
  validation {
    condition     = (var.kernel_gateway_app_settings_lifecycle_config_arns == null ? true : (alltrue([for i in var.kernel_gateway_app_settings_lifecycle_config_arns : can(regex("^arn:aws:sagemaker:\\w+", i))])))
    error_message = "The lifecycle_config_arn is required and the allowed format is arn:aws:sagemaker:<region>:<account-id>:studio-lifecycle-config/<lifecycle_config_arn_name>."
  }
}

variable "app_image_config_name" {
  description = "The name of the App Image Config."
  type        = string
  default     = null
}

variable "image_name" {
  description = "The name of the Custom Image."
  type        = string
  default     = null
}

variable "image_version_number" {
  description = "The version number of the Custom Image."
  type        = string
  default     = null
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