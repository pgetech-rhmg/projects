#variables for aws_lambda_layer_version
variable "layer_version_layer_name" {
  description = "Unique name for your Lambda Layer"
  type        = string
}

variable "layer_version_compatible_architectures" {
  description = "List of Architectures this layer is compatible with. Currently x86_64 and arm64 can be specified"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.layer_version_compatible_architectures == null,
      var.layer_version_compatible_architectures == "x86_64",
    var.layer_version_compatible_architectures == "arm64"])
    error_message = "Error! values for architectures are x86_64 and arm64."
  }
}

variable "layer_version_compatible_runtimes" {
  description = "A list of Runtimes this layer is compatible with. Up to 15 runtimes can be specified"
  type        = list(string)
}

variable "layer_version_description" {
  description = "Description of what your Lambda Layer does"
  type        = string
  default     = null
}

variable "layer_version_license_info" {
  description = " License info for your Lambda Layer"
  type        = string
  default     = null
}

variable "layer_skip_destroy" {
  description = "Whether to retain the old version of a previously deployed Lambda Layer."
  type        = bool
  default     = false
}

variable "s3_bucket" {
  description = "S3 bucket location containing the function's deployment package. Conflicts with filename and image_uri. This bucket must reside in the same AWS region where you are creating the Lambda function"
  type        = string
}

variable "s3_key" {
  description = " S3 key of an object containing the function's deployment package. Conflicts with filename and image_uri"
  type        = string
}

variable "s3_object_version" {
  description = "Object version containing the function's deployment package. Conflicts with filename and image_uri"
  type        = string
  default     = null
}

#variables for aws_lambda_layer_version_permission
variable "layer_version_permission_action" {
  description = "Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documantation"
  type        = string
  default     = null
}

variable "layer_version_permission_principal" {
  description = "AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely"
  type        = string
}

variable "layer_version_permission_statement_id" {
  description = "The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for"
  type        = string
  default     = null
}