# Variables for flow_definition
variable "flow_definition_name" {
  description = "The name of your flow definition"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]*$", var.flow_definition_name))
    error_message = "Error! Name may contain letters (A-Z), numbers (0-9), hyphens (-)."
  }
}

variable "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) of the role needed to call other services on your behalf."
  type        = string
}

variable "human_task_ui_arn" {
  description = "The Amazon Resource Name (ARN) of the human task user interface."
  type        = string
}

variable "task_availability_lifetime_in_seconds" {
  description = "The length of time that a task remains available for review by human workers. Valid value range between 1 and 864000."
  type        = number

  validation {
    condition     = var.task_availability_lifetime_in_seconds >= 1 && var.task_availability_lifetime_in_seconds <= 864000
    error_message = "Error! Valid values for task_availability_lifetime_in_seconds range between 1 and 864000."
  }
}

variable "task_count" {
  description = "The number of distinct workers who will perform the same task on each object. Valid value range between 1 and 3."
  type        = number

  validation {
    condition     = var.task_count >= 1 && var.task_count <= 3
    error_message = "Error! Valid values for task_count range between 1 and 3."
  }
}

variable "task_description" {
  description = "A description for the human worker task."
  type        = string
  default     = null

  validation {
    condition     = var.task_description != null ? can(regex("^[A-Za-z0-9 -.]*$", var.task_description)) : true
    error_message = "Error! Name may contain letters (A-Z), numbers (0-9), space, hyphens (-) and . (period)."
  }
}

variable "task_keywords" {
  description = "An array of keywords used to describe the task so that workers can discover the task."
  type        = list(string)
  default     = null
}

variable "task_time_limit_in_seconds" {
  description = "The amount of time that a worker has to complete a task. The default value is 3600 seconds."
  type        = number
  default     = 3600
}

variable "task_title" {
  description = "A title for the human worker task."
  type        = string
}

variable "workteam_arn" {
  description = "The Amazon Resource Name (ARN) of the human task user interface. Amazon Resource Name (ARN) of a team of workers."
  type        = string
}

variable "public_workforce_task_price" {
  description = "Defines the amount of money paid to an Amazon Mechanical Turk worker for each task performed. Valid value of cents range between 0 and 99. Valid value of dollars range between 0 and 2. Valid value of tenth_fractions_of_a_cent range between 0 and 9."
  #As per Terraform registry data type 'map(any)' should contain elements of the same type, for the block 'public_workforce_task_price'
  #the variable 'public_workforce_task_price' have elements of different types and hence we have to use type 'any'.
  type    = any
  default = null

  validation {
    condition     = var.public_workforce_task_price != null ? alltrue(flatten([for ka, va in var.public_workforce_task_price : [for ki, vi in va : vi >= 0 && vi <= 99 if ki == "cents"] if ka == "amount_in_usd"])) : true
    error_message = "Error! Valid value for cents range between 0 and 99."
  }

  validation {
    condition     = var.public_workforce_task_price != null ? alltrue(flatten([for ka, va in var.public_workforce_task_price : [for ki, vi in va : vi >= 0 && vi <= 2 if ki == "dollars"] if ka == "amount_in_usd"])) : true
    error_message = "Error! Valid value for dollars range between 0 and 2."
  }

  validation {
    condition     = var.public_workforce_task_price != null ? alltrue(flatten([for ka, va in var.public_workforce_task_price : [for ki, vi in va : vi >= 0 && vi <= 9 if ki == "tenth_fractions_of_a_cent"] if ka == "amount_in_usd"])) : true
    error_message = "Error! Valid value range between 0 and 9."
  }
}

variable "human_loop_activation_config" {
  description = "An object containing information about the events that trigger a human workflow."
  type        = map(any)
  default     = null
}

variable "human_loop_request_source" {
  description = "Container for configuring the source of human task requests. Use to specify if Amazon Rekognition or Amazon Textract is used as an integration source. Valid values of aws_managed_human_loop_request_source are: AWS/Rekognition/DetectModerationLabels/Image/V3 and AWS/Textract/AnalyzeDocument/Forms/V1."
  type        = map(any)
  default     = null

  validation {
    condition     = var.human_loop_request_source != null ? alltrue(flatten([for ki, vi in var.human_loop_request_source : contains(["AWS/Rekognition/DetectModerationLabels/Image/V3", "AWS/Textract/AnalyzeDocument/Forms/V1"], vi) if ki == "aws_managed_human_loop_request_source"])) : true
    error_message = "Error! Valid values are: AWS/Rekognition/DetectModerationLabels/Image/V3 and AWS/Textract/AnalyzeDocument/Forms/V1."
  }
}

variable "s3_output_path" {
  description = "The Amazon S3 path where the object containing human output will be made available. If the user needs to provide some specific folder within the s3 bucket, pass the value like: s3-bucket-name/test-folder."
  type        = string
}

variable "kms_key_id" {
  description = "The Amazon Key Management Service (KMS) key ARN for server-side encryption."
  type        = string

}

# Variables for tags
variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}