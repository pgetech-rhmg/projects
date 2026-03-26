#Variables for endpoint_access
variable "name" {
  description = "The Redshift-managed VPC endpoint name."
  type        = string
}

variable "subnet_group_name" {
  description = "The subnet group from which Amazon Redshift chooses the subnet to deploy the endpoint."
  type        = string
}

variable "cluster_identifier" {
  description = "The cluster identifier of the cluster to access."
  type        = string
}

variable "vpc_sg_ids" {
  description = "The security group that defines the ports, protocols, and sources for inbound traffic that you are authorizing into your endpoint."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for i in var.vpc_sg_ids : can(regex("^sg+", i))])
    error_message = "Enter valid security group ids."
  }
}

variable "resource_owner" {
  #Using type as string, incase 0 becomes the first digit it gets omitted so we using account number as string.
  description = "The Amazon Web Services account ID of the owner of the cluster. This is only required if the cluster is in another Amazon Web Services account."
  type        = string
  default     = ""
  validation {
    condition     = length(var.resource_owner) == 12 || length(var.resource_owner) == 0
    error_message = "Enter valid resource owner nummber length of the resource owner number must be 12 digits."
  }
}