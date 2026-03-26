
variable "cluster_name" {
  description = "Enter the name of the cluster."
  type        = string
}


variable "autoscaling_group_name" {
  description = "Enter the Autoscaling group name of the cluster."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "sns_topic_cloudwatch_alarm_arn" {
  description = "Enter the sns_topic_cloudwatch_alarm_arn to send alerts to"
  type        = string
}