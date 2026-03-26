variable "cluster_identifier" {
  description = "The name of the Redshift Cluster to attach IAM Roles."
  type        = string
}

variable "iam_role_arns" {
  description = "A list of IAM Role ARNs to associate with the cluster. A Maximum of 10 can be associated to the cluster at any time."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for i in var.iam_role_arns : can(regex("^arn:aws:iam::\\w+", i)) if i != ""])
    error_message = "Error! Provide list of iam role arns, value should be in form of 'arn:aws:iam::xxxxxx'!"
  }
}