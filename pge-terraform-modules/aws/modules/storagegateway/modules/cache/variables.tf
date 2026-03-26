# Variables for Storage gateway cache

variable "gateway_arn" {
  description = "The Amazon Resource Name (ARN) of the gateway."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:storagegateway:\\w+(?:-\\w+)+:[[:digit:]]{12}:gateway/([a-zA-Z0-9])+(.*)$", var.gateway_arn))
    error_message = "Error! Please provide gateway arn in form of arn:aws:storagegateway:<region>:<account-id>:gateway/<gateway_id>."
  }
}

variable "disk_id" {
  description = "Local disk identifier."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}", var.disk_id)) || can(regex("^pci-[[:digit:]]{4}:[[:digit:]]{2}:[[:digit:]]{2}.[[:digit:]]{1}-scsi-[[:digit:]]{1}:[[:digit:]]{1}:[[:digit:]]{1}:[[:digit:]]{1}", var.disk_id))
    error_message = "Error! Enter a valid disk_id."
  }
}