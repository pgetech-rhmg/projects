variable "availability_zone" {
  description = "The names of the availability zone"
  type        = string
}

variable "iops" {
  description = "The amount of IOPS to provision for the disk. Only valid for type of io1, io2 or gp3."
  type        = number
  default     = null
}

variable "multi_attach_enabled" {
  description = "Specifies whether to enable Amazon EBS Multi-Attach. Multi-Attach is supported exclusively on io1 volumes."
  type        = bool
  default     = false
}

variable "size" {
  description = "The size of the drive in GiBs"
  type        = string
}

variable "type" {
  description = "The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1."
  type        = string
  default     = "gp2"
  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"], var.type)
    error_message = "Valid values for type are (standard, gp2, gp3, io1, io2, sc1, st1). Please select on these as type parameter."
  }
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "throughput" {
  description = "The throughput that the volume supports, in MiB/s. Only valid for type of gp3."
  type        = string
  default     = null
}

variable "device_name" {
  description = "The device name to expose to the instance"
  type        = string
}

variable "instance_id" {
  description = "Id of the ec2 instance."
  type        = list(string)

  validation {
    condition = alltrue([
      for i in var.instance_id : can(regex("^i-\\w+", i))
    ])
    error_message = "Aws Ec2 instance id is required and allowed format of the instance id  is i-#################."
  }
}