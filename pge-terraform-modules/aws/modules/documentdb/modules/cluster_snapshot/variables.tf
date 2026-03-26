#Variables for documentdb snapshot 
variable "db_cluster_identifier" {
  description = "The DocDB Cluster Identifier from which to take the snapshot."
  type        = string
}

variable "db_cluster_snapshot_identifier" {
  description = "The Identifier for the snapshot."
  type        = string
}

variable "timeouts" {
  description = "The cluster timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours."
  type        = map(string)
  default     = {}
}