#Variables for tags
variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#Variables for workflow
variable "glue_workflow_name" {
  description = "The name you assign to this workflow."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.glue_workflow_name))
    error_message = "Error! workflow name can only contain alphanumeric characters,  letters (A-Z), numbers (0-9), hyphens (-), or underscores (_),"
  }
}

variable "glue_workflow_description" {
  description = "Description of the workflow."
  type        = string
  default     = null
}

variable "glue_workflow_default_run_properties" {
  description = "A map of default run properties for this workflow. These properties are passed to all jobs associated to the workflow."
  type        = map(string)
  default     = {}
}

variable "glue_workflow_max_concurrent_runs" {
  description = "Prevents exceeding the maximum number of concurrent runs of any of the component jobs. If you leave this parameter blank, there is no limit to the number of concurrent workflow runs."
  type        = number
  default     = null
}