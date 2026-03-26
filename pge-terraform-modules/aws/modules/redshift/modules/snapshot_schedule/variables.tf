# Variables Declared for Redshift Snapshot Schedule
variable "snapshot_schedule_identifier" {
  description = "The snapshot schedule identifier. If omitted, Terraform will assign a random, unique identifier."
  type        = string
  default     = null
}

variable "snapshot_schedule_description" {
  description = "The description of the snapshot schedule."
  type        = string
  default     = null
}

variable "snapshot_schedule_definitions" {
  description = "The definition of the snapshot schedule."
  type        = list(string)
  default     = []
}

variable "snapshot_schedule_force_destroy" {
  description = "Whether to destroy all associated clusters with this snapshot schedule on deletion. Must be enabled and applied before attempting deletion."
  type        = bool
  default     = null
}

variable "snapshot_schedule_association" {
  description = "variable declared for iteration."
  type        = list(string)
}
variable "snapshot_cluster_identifier" {
  description = "cluster to associate with snapshot schedule"
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