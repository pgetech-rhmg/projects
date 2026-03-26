variable "name" {
  description = "Name of the stream consumer."
  type        = string
}

variable "stream_arn" {
  description = " Amazon Resource Name (ARN) of the data stream the consumer is registered with."
  type        = string
  validation {
    condition     = alltrue([can(regex("^arn:aws:kinesis:\\w+", var.stream_arn))])
    error_message = "Error! Provide stream arn in form of 'arn:aws:kinesis:xxxxxx'!"
  }
}