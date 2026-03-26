variable "instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 1
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = true
}

variable "availability_zone" {
  description = "The EC2 Availability Zone that the DB instance is created in."
  type        = string
  default     = null
}

variable "cluster_identifier" {
  description = "The EC2 Availability Zone that the DB instance is created in."
  type        = string
}

variable "engine" {
  description = " The name of the database engine to be used for the DocDB instance."
  type        = string
  default     = "docdb"
}

variable "identifier" {
  description = "The identifier for the DocDB instance, if omitted, Terraform will assign a random, unique identifier."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance class to use."
  type        = string
  validation {
    condition = contains(["db.r6g.large", "db.r6g.xlarge", "db.r6g.2xlarge", "db.r6g.4xlarge", "db.r6g.8xlarge",
      "db.r6g.12xlarge", "db.r6g.16xlarge", "db.r5.large", "db.r5.xlarge", "db.r5.xlarge", "db.r5.4xlarge", "db.r5.8xlarge",
      "db.r5.8xlarge", "db.r5.16xlarge", "db.r5.16xlarge", "db.r4.large", "db.r4.xlarge", "db.r4.2xlarge", "db.r4.4xlarge",
    "db.r4.8xlarge", "db.r4.16xlarge", "db.t4g.medium", "db.t3.medium"], var.instance_class)
    error_message = "Error! enter a valid value for instance_class."
  }
}

variable "preferred_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: ddd:hh24:mi-ddd:hh24:mi. Eg: Mon:00:00-Mon:03:00."
  type        = string
  default     = null
}

variable "promotion_tier" {
  description = "Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoter to writer."
  type        = number
  default     = 0
}

variable "timeouts" {
  description = "aws_docdb_cluster_instance provides the following Timeouts configuration options: create, update, delete."
  type        = map(string)
  default     = {}
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resources tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}