module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

### variables for aws_backup_plan ###

variable "aws_backup_plan_name" {
  description = "The display name of a backup plan"
  type        = string
  #   default     = null
  validation {
    condition     = (length(var.aws_backup_plan_name) > 0)
    error_message = "Backup plan name can't be empty."
  }
}

variable "aws_backup_plan_rule" {
  description = "Enable Windows VSS backup option and create a VSS Windows backup"
  type        = list(any)
  default     = []
}

variable "windows_vss_backup" {
  description = "Enable Windows VSS backup option and create a VSS Windows backup"
  type        = bool
  default     = false
}