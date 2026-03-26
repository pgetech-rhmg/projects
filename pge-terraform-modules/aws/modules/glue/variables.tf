# Variable for tags

variable "tags" {
  description = "A map of tags to populate on the created table."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for Glue Job

variable "glue_job_name" {
  description = "The name you assign to this job. It must be unique in your account."
  type        = string
}

variable "glue_job_role_arn" {
  description = "The ARN of the IAM role associated with this job."
  type        = string
}

variable "glue_job_command" {
  description = "The command of the job. Includes 'name', 'script_location' and 'python_version'."
  type        = list(map(string))
}

variable "glue_job_connections" {
  description = "The list of connections used for this job."
  type        = list(string)
  default     = []
}

variable "glue_job_default_arguments" {
  description = "The map of default arguments for this job. You can specify arguments here that your own job-execution script consumes, as well as arguments that AWS Glue itself consumes. For information about how to specify and consume your own Job arguments, see the Calling AWS Glue APIs in Python topic in the developer guide. For information about the key-value pairs that AWS Glue consumes to set up your job, see the Special Parameters Used by AWS Glue topic in the developer guide."
  type        = map(string)
  default     = {}
}

variable "non_overridable_arguments" {
  description = "Non-overridable arguments for this job, specified as name-value pairs."
  type        = map(string)
  default     = {}
}

variable "glue_job_description" {
  description = "Description of the job."
  type        = string
  default     = null
}

variable "max_concurrent_runs" {
  description = "The maximum number of concurrent runs allowed for a job. The default is 1."
  type        = number
  default     = 1
}

variable "glue_job_glue_version" {
  description = "The version of glue to use, for example '1.0'. For information about available versions, see the AWS Glue Release Notes."
  type        = string
  default     = null
}

variable "glue_job_max_capacity" {
  description = "The maximum number of AWS Glue data processing units (DPUs) that can be allocated when this job runs. Required when pythonshell is set, accept either 0.0625 or 1.0. Use number_of_workers and worker_type arguments instead with glue_version 2.0 and above."
  type        = number
  default     = null
}

variable "glue_job_max_retries" {
  description = "The maximum number of times to retry this job if it fails."
  type        = number
  default     = null
}

variable "notify_delay_after" {
  description = "Notification property of the job. After a job run starts, the number of minutes to wait before sending a job run delay notification."
  type        = number
  default     = null
}

variable "glue_job_timeout" {
  description = "The job timeout in minutes. The default is 2880 minutes (48 hours) for glueetl and pythonshell jobs, and null (unlimted) for gluestreaming jobs."
  type        = number
  default     = 2880 # time in minutes , 48 hours
}

variable "glue_job_security_configuration" {
  description = "The name of the Security Configuration to be associated with the job."
  type        = string
}

variable "glue_job_worker_type" {
  description = "The type of predefined worker that is allocated when a job runs. Accepts a value of Standard, G.1X, or G.2X."
  type        = string
  default     = null
}

variable "glue_job_number_of_workers" {
  description = "The number of workers of a defined workerType that are allocated when a job runs."
  type        = number
  default     = null
}
