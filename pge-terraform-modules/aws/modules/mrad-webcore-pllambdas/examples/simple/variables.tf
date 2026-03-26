variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "app_id" {
  type = string
}

variable "data_classification" {
  type = string
}

variable "cris" {
  type = string
}

variable "notify" {
  type = list(string)
}

variable "owner" {
  type = list(string)
}

variable "compliance" {
  type = list(string)
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "create_pttup_pipeline" {
  description = "Whether to create the PTT pipeline"
  type        = bool
  default     = false
}

variable "create_atrisk_pipeline" {
  description = "Whether to create the ATRISK pipeline"
  type        = bool
  default     = false
}

variable "create_gissync_pipeline" {
  description = "Whether to create the GIS SYNC pipeline"
  type        = bool
  default     = false
}

variable "create_gisseed_pipeline" {
  description = "Whether to create the GIS SEED pipeline"
  type        = bool
  default     = false
}

variable "create_dbsched_pipeline" {
  description = "Whether to create the DB Scheduler pipeline"
  type        = bool
  default     = false
}

variable "create_nlbman_pipeline" {
  description = "Whether to create the NLB Manager pipeline"
  type        = bool
  default     = false
}
