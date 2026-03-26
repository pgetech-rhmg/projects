
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

# Variables for aws_elasticache_global_replication_group

variable "global_suffix" {
  description = "The suffix name of a Global Datastore. If global_replication_group_id_suffix is changed, creates a new resource."
  type        = string
}

variable "primary_replication_group_id" {
  description = "The ID of the primary cluster that accepts writes and will replicate updates to the secondary cluster. If primary_replication_group_id is changed, creates a new resource."
  type        = string
}

variable "cluster_id" {
  description = "Replication group identifier. This parameter is stored as a lowercase string."
  type        = string
}

variable "redis_engine_version" {
  description = "Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine_version_actual."
  type        = string
  default     = null
}