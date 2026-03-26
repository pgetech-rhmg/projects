#Variables for cluster snapshot
variable "db_cluster_identifier" {
  description = "The DB Cluster Identifier from which to take the snapshot. The DB cluster should exist in the AWS account to take the snapshot. This is a prerequisite to meet before running the example."
  type        = string
}

variable "db_cluster_snapshot_identifier" {
  description = "The Identifier for the snapshot."
  type        = string
}

variable "snapshot_create_timeouts" {
  description = "How long to wait for the snapshot to be available. We should use the format like 20m for 20 minutes, 10s for ten seconds, or 2h for two hours."
  type        = string
  default     = "20m"
}