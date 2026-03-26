variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "enable_pod_identity" {
  description = "Determines whether to enable support for EKS pod identity"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "The Kubernetes namespace where Grafana Loki will be deployed"
  type        = string
  default     = "monitoring"
}

variable "service_account" {
  description = "The Kubernetes service account for Grafana Loki"
  type        = string
  default     = "loki-sa"
}

variable "bucket_name_chunks" {
  description = "The name of the S3 bucket for Loki chunks"
  type        = string
  default     = ""
}

variable "bucket_name_ruler" {
  description = "The name of the S3 bucket for Loki ruler"
  type        = string
  default     = ""
}

variable "loki_role_name" {
  description = "The name of the IAM role for Grafana Loki"
  type        = string
  default     = ""
}

variable "loki_role_description" {
  description = "The description for the IAM role for Grafana Loki"
  type        = string
  default     = "IAM role for Grafana Loki to access S3 buckets"
}