# variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# variables for endpoint_configuration
variable "name" {
  description = "The name of the endpoint configuration. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]", var.name))
    error_message = "Allowed alphanumeric characters: a-z, A-Z, 0-9, and - (hyphen)."
  }
  validation {
    condition     = anytrue([length(var.name) <= 63])
    error_message = "Maximum of 63 alphanumeric characters. Can include hyphens (-), but not spaces. Must be unique within your account in an AWS Region."
  }
}

variable "kms_key_id" {
  description = "Amazon Resource Name (ARN) of a AWS Key Management Service key that Amazon SageMaker uses to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint."
  type        = string
  default     = null
}

#variable "kms_key_id" {
#description = "When notebook_output_option is Allowed, the AWS Key Management Service (KMS) encryption key ID used to encrypt the notebook cell output in the Amazon S3 bucket."
# type        = string
# validation {
#   condition = var.kms_key_id == null ? true : can(regex("^arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.kms_key_id)
#   error_message = "kms_key_id arn is required and the allowed format is arn:aws:kms:<region>:<account-id>:key/<key_id>."
# }
#}


# Instance count and instance type conflicts with serverless_config.
variable "initial_instance_count" {
  description = "Initial number of instances used for auto-scaling."
  type        = number
  default     = null
}

variable "instance_type" {
  description = "The type of instance to start."
  type        = string
  default     = null
}

variable "accelerator_type" {
  description = "The size of the Elastic Inference (EI) instance to use for the production variant."
  type        = string
  default     = null
}

variable "initial_variant_weight" {
  description = "Determines initial traffic distribution among all of the models that you specify in the endpoint configuration."
  type        = number
  default     = 1.0
}

variable "model_name" {
  description = "The name of the model to use."
  type        = string
}

variable "variant_name" {
  description = "The name of the variant. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "serverless_config" {
  description = "Specifies configuration for how an endpoint performs asynchronous inference."
  # The data type 'map(any)' should contain elements of the same type, for the block 'serverless_config'
  # the variable 'serverless_config' have elements of different types and hence we have to use type 'any' and passing null values results in valdiation breach due to the {} in for_each expression.
  type    = any
  default = {}
  validation {
    condition     = alltrue([for ki, vi in var.serverless_config : vi >= 1 && vi <= 200 if ki == "max_concurrency"])
    error_message = "Valid values for max_concurrency are between 1 and 200."
  }
  validation {
    condition     = alltrue([for ki, vi in var.serverless_config : contains([1024, 2048, 3072, 4096, 5120, 6144], vi) if ki == "memory_size_in_mb"])
    error_message = "Valid values for memory_size_in_mb are in 1 GB increments: 1024 MB, 2048 MB, 3072 MB, 4096 MB, 5120 MB, or 6144 MB."
  }
}

variable "async_inference_config" {
  description = "Specifies configuration for how an endpoint performs asynchronous inference. This is a required field in order for your Endpoint to be invoked."
  # The data type 'map(any)' should contain elements of the same type, for the block 'async_inference_config'
  # the variable 'async_inference_config' have elements of different types and hence we have to use type 'any'.
  type    = any
  default = null
}

variable "data_capture_config" {
  description = "Specifies the parameters to capture input/output of SageMaker models endpoints."
  # The data type 'map(any)' should contain elements of the same type, for the block 'async_inference_config'
  # the variable 'async_inference_config' have elements of different types and hence we have to use type 'any'.
  type    = any
  default = null
}