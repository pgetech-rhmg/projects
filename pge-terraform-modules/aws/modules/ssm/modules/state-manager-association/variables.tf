module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

variable "name" {
  type        = string
  description = " SSM state manager asscoation name"

}

variable "ssm_document_name" {
  type        = string
  description = " SSM document name"

}

variable "schedule_expression" {
  type        = string
  description = "SSM association schedule expression"
}

variable "approved_patches_compliance_level" {
  type        = string
  description = "Defines the compliance level for approved patches. This means that if an approved patch is reported as missing, this is the severity of the compliance violation. Valid compliance levels include the following: CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL, UNSPECIFIED. The default value is UNSPECIFIED."
}

variable "s3_bucket_name" {
  type        = string
  description = " S3 bucket for SSM state manager asscoation"

}

variable "s3_key_prefix" {
  type        = string
  description = " S3 bucket prefix for SSM state manager logs"

}


variable "association_targets" {
  description = "The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2."
  type = list(object({
    key : string
    values : list(string)
    }
    )
  )
  default = []

}

variable "automation_target_parameter_name" {
  type        = string
  description = "Input automation_target_parameter_name"
  default     = null

}

variable "document_parameters" {
  description = "The Document paramters for Automation or RunCommand "
  type        = map(string)
  default     = {}

}

variable "max_concurrency" {
  type        = string
  description = "Input max_concurrency in either number or percentage"
  default     = "20%"

}

variable "apply_only_at_cron_interval" {
  description = "when you create a new or update associations, the system runs it immediately and then according to the schedule you specified. Enable this option if you do not want an association to run immediately after you create or update it. This parameter is not supported for rate expressions. Default: false."
  type        = bool
  default     = false
}