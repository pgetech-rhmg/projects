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
  description = "The Kubernetes namespace where Grafana Tempo will be deployed"
  type        = string
  default     = "monitoring"
}

variable "service_account" {
  description = "The Kubernetes service account for Grafana Tempo"
  type        = string
  default     = "tempo-sa"
}

variable "bucket_name_traces" {
  description = "The name of the S3 bucket for Tempo traces"
  type        = string
  default     = ""
}

variable "tempo_role_name" {
  description = "The name of the IAM role for Grafana Tempo"
  type        = string
  default     = ""
}

variable "tempo_role_description" {
  description = "The description for the IAM role for Grafana Tempo"
  type        = string
  default     = "IAM role for Grafana Tempo to access S3 buckets"
}