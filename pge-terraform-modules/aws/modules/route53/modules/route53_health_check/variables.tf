variable "reference_name" {
  description = "A reference name used in Caller Reference"
  type        = string
  default     = null
}

variable "fqdn" {
  description = "The fully qualified domain name of the endpoint to be checked"
  type        = string
  default     = null
}

variable "ip_address" {
  description = "The IP address of the endpoint to be checked"
  type        = string
  default     = null
}

variable "port" {
  description = "The port of the endpoint to be checked"
  type        = number
  default     = null
}

variable "type" {
  description = "The protocol to use when performing health checks"
  type        = string
}

variable "failure_threshold" {
  description = "The number of consecutive health checks that an endpoint must pass or fail"
  type        = number
  default     = null
}

variable "request_interval" {
  description = "The number of seconds between the time that Amazon Route 53 gets a response from your endpoint and the time that it sends the next health-check request"
  type        = number
  default     = null
}

variable "resource_path" {
  description = "The path that you want Amazon Route 53 to request when performing health checks"
  type        = string
  default     = null
}

variable "search_string" {
  description = "String searched in the first 5120 bytes of the response body for check to be considered healthy"
  type        = string
  default     = null
}

variable "measure_latency" {
  description = "A Boolean value that indicates whether you want Route 53 to measure the latency between health checkers in multiple AWS regions and your endpoint and to display CloudWatch latency graphs in the Route 53 console"
  type        = bool
  default     = null
}

variable "invert_healthcheck" {
  description = "A boolean value that indicates whether the status of health check should be inverted"
  type        = bool
  default     = null
}

variable "disabled" {
  description = "A boolean value that stops Route 53 from performing health checks"
  type        = bool
  default     = null
}

variable "enable_sni" {
  description = "A boolean value that indicates whether Route53 should send the fqdn to the endpoint when performing the health check"
  type        = bool
  default     = null
}

variable "child_healthchecks" {
  description = "For a specified parent health check, a list of HealthCheckId values for the associated child health checks"
  type        = list(string)
  default     = null
}

variable "child_health_threshold" {
  description = "The minimum number of child health checks that must be healthy for Route 53 to consider the parent health check to be healthy"
  type        = number
  default     = null
}

variable "cloudwatch_alarm_name" {
  description = "The name of the CloudWatch alarm"
  type        = string
  default     = null
}

variable "cloudwatch_alarm_region" {
  description = "The CloudWatchRegion that the CloudWatch alarm was created in"
  type        = string
  default     = null
}

variable "insufficient_data_health_status" {
  description = "The status of the health check when CloudWatch has insufficient data about the state of associated alarm"
  type        = string
  default     = null
}

variable "regions" {
  description = "A list of AWS regions that you want Amazon Route 53 health checkers to check the specified endpoint from"
  type        = list(string)
  default     = null
}

variable "routing_control_arn" {
  description = "The Amazon Resource Name (ARN) for the Route 53 Application Recovery Controller routing control"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

# validate the tags passed
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.1"
  tags    = var.tags
}