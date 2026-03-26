variable "domain_name" {
  description = "OpenSearch Domain name"
  type        = string
}

variable "engine_version" {
  description = "Opensearch engine version"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "vpc_options" {
  description = "Configuration block for VPC options"
  type        = list(any)
}

variable "advanced_security_options" {
  description = "Advanced security options"
  type        = list(any)
}

variable "domain_endpoint_options" {
  description = "Domain Endpoint options block"
  type        = list(any)
}

variable "cluster_config" {
  description = "Configuration block for Cluster"
  type        = list(any)
  default     = []
}

variable "node_to_node_encryption_options" {
  description = "Configuration block for encryption options"
  type        = list(any)
  default     = []
}

variable "ebs_options" {
  description = "Configuration block for EBS options"
  type        = list(any)
  default     = []
}

variable "log_publishing_options" {
  description = "Configuration block for log publishing options"
  type        = list(any)
}

variable "encrypt_at_rest_options" {
  description = "Configuration block for encryption at rest options"
  type        = list(any)
}

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(any)
  default     = {}
}

variable "advanced_options" {
  description = "Key-value string pairs to specify advanced configuration options"
  type        = map(string)
}