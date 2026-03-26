#Variables for Redshift Cluster Creation
variable "cluster_identifier" {
  description = "The Cluster Identifier. Must be a lower case string."
  type        = string
}

variable "database_name" {
  description = "The name of the first database to be created when the cluster is created. If you do not provide a name, Amazon Redshift will create a default database called dev."
  type        = string
  default     = null
}

variable "node_type" {
  description = "The node type to be provisioned for the cluster."
  type        = string
}

variable "cluster_type" {
  description = "The cluster type to use. Either single-node or multi-node"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.cluster_type == "single-node",
    var.cluster_type == "multi-node"])
    error_message = "Error! values for cluster type are 'single-node' & 'multi-node'."
  }
}

variable "master_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Password must contain at least 8 chars and contain at least one uppercase letter, one lowercase letter, and one number."
  type        = string
  validation {
    condition     = (length(var.master_password)) >= 16 && (!can(regex("[@/]", var.master_password)))
    error_message = "Master password must be at least sixteen characters long and cannot contain a / (slash), (double quote) or @ (at symbol)."
  }
}

# As per SAF Rule
variable "master_username" {
  description = "Username for the master DB user."
  type        = string
  validation {
    condition     = !can(regex("awsuser", var.master_username))
    error_message = "Default user name 'awsuser' is not allowed."
  }
}

variable "vpc_security_group_ids" {
  description = "A list of Virtual Private Cloud (VPC) security groups to be associated with the cluster."
  type        = list(string)
  validation {
    condition     = alltrue([for i in var.vpc_security_group_ids : can(regex("^sg-\\w+", i))])
    error_message = "Error! Provide list of vpc_security_group_ids, value should be in form of 'sg-xxxxxxxx'!"
  }
}

variable "cluster_subnet_group_name" {
  description = "The name of a cluster subnet group to be associated with this cluster. If this parameter is not provided the resulting cluster will be deployed outside virtual private cloud (VPC)."
  type        = string
}

variable "redshift_availability_zone" {
  description = <<-DOC
    availability_zone:
       The EC2 Availability Zone (AZ) in which you want Amazon Redshift to provision the cluster. For example, if you have several EC2 instances running in a specific Availability Zone, then you might want the cluster to be provisioned in the same zone in order to decrease network latency. Can only be changed if availability_zone_relocation_enabled is true.
    availability_zone_relocation_enabled:
       If true, the cluster can be relocated to another availabity zone, either automatically by AWS or when requested. Default is false. Available for use on clusters from the RA3 instance family.
  DOC
  type = object({
    availability_zone_relocation_enabled = bool
    availability_zone                    = string
  })
  default = {
    availability_zone                    = null
    availability_zone_relocation_enabled = false
  }
  validation {
    condition     = var.redshift_availability_zone.availability_zone != null ? var.redshift_availability_zone.availability_zone_relocation_enabled == true : var.redshift_availability_zone.availability_zone_relocation_enabled == false
    error_message = "Availability Zone can only be changed if 'availability_zone_relocation_enabled' is true."
  }
}

variable "preferred_maintenance_window" {
  type        = string
  description = "The weekly time range (in UTC) during which automated cluster maintenance can occur. Format: ddd:hh24:mi-ddd:hh24:mi"
  default     = null
  validation {
    condition     = anytrue([can(regex("[a-z]+:[0-9]+:[0-9]+-[a-z]+:[0-9]+:[0-9]+", var.preferred_maintenance_window)) || var.preferred_maintenance_window == null])
    error_message = "Error: Format for maintenance_window is eg 'wed:04:00-wed:04:30'."
  }
}

variable "cluster_parameter_group_name" {
  description = "The name of the parameter group to be associated with this cluster."
  type        = string
  default     = null
}

#As per SAF Rule
variable "automated_snapshot_retention_period" {
  description = "The number of days that automated snapshots are retained. If the value is 0, automated snapshots are disabled. Even if automated snapshots are disabled, you can still create manual snapshots when you want with create-cluster-snapshot. Default is 1."
  type        = number
  default     = 15
  validation {
    condition     = var.automated_snapshot_retention_period >= 15
    error_message = "Must be at least 15 days."
  }
}

variable "port" {
  description = "The port number on which the cluster accepts incoming connections. Valid values are between 1115 and 65535."
  type        = number
  default     = 5439
  validation {
    condition     = var.port >= 1115 && var.port <= 65535
    error_message = "Error:Valid values are between 1115 and 65535."
  }
}

variable "cluster_version" {
  description = "The version of the Amazon Redshift engine software that you want to deploy on the cluster. The version selected runs on all the nodes in the cluster."
  type        = string
  default     = null
  validation {
    condition     = anytrue([can(regex("^1.0.[0-9]+", var.cluster_version)) || var.cluster_version == null])
    error_message = "Error: list of available versions :https://docs.aws.amazon.com/redshift/latest/mgmt/cluster-versions.html."
  }
}

variable "aqua_configuration_status" {
  description = "The value represents how the cluster is configured to use AQUA (Advanced Query Accelerator) after the cluster is restored."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.aqua_configuration_status == "enabled",
    var.aqua_configuration_status == "disabled", var.aqua_configuration_status == null, var.aqua_configuration_status == "auto"])
    error_message = "Error! values for aqua_configuration_status are 'enabled' & 'disabled' & 'auto'."
  }
}

variable "number_of_nodes" {
  description = "The number of compute nodes in the cluster."
  type        = number
  default     = null
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key."
  type        = string
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot of the cluster is created before Amazon Redshift deletes the cluster."
  type        = bool
  default     = null
}

variable "final_snapshot_identifier" {
  description = "The identifier of the final snapshot that is to be created immediately before deleting the cluster."
  type        = string
  default     = null
}

variable "snapshot_identifier" {
  description = "The name of the snapshot from which to create the new cluster."
  type        = string
  default     = null
}

variable "snapshot_cluster_identifier" {
  description = "The name of the cluster the source snapshot was created from."
  type        = string
  default     = null
}

variable "owner_account" {
  description = "The AWS customer account used to create or copy the snapshot. "
  type        = string
  default     = null
}

variable "iam_roles" {
  description = "(Optional) A list of IAM Role ARNs to associate with the cluster."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for i in var.iam_roles : can(regex("^arn:aws:iam::\\w+", i)) if i != ""])
    error_message = "Error! Provide list of iam role arns, value should be in form of 'arn:aws:iam::xxxxxx'!"
  }
}

variable "maintenance_track_name" {
  description = "The name of the maintenance track for the restored cluster."
  type        = string
  default     = null
}

variable "manual_snapshot_retention_period" {
  description = "The default number of days to retain a manual snapshot."
  type        = number
  default     = 15
  validation {
    condition     = var.manual_snapshot_retention_period >= 15
    error_message = "Must be at least 15 days."
  }
}

variable "timeouts" {
  description = "The cluster timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours."
  type        = map(string)
  default     = {}
}

variable "snapshot_copy" {
  type = map(object({
    destination_region       = string
    retention_period         = number
    snapshot_copy_grant_name = string
  }))
  default = {}
  validation {
    condition     = alltrue([for ki, vi in var.snapshot_copy : can(regex("[a-z][a-z]-[a-z]+-[1-9]", vi)) if ki == "destination_region"])
    error_message = "Valid value for destination_region is eg:us-east-1."
  }
  validation {
    condition     = alltrue([for ki, vi in var.snapshot_copy : vi > 0 if ki == "retention_period"])
    error_message = "Value of retention_period should not be zero."
  }
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

variable "s3_key_prefix" {
  description = "The prefix applied to the log file names."
  type        = string
}

#Variables for Tags
variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}