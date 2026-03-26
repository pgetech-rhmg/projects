variable "name" {
  description = "A unique name for this"
  type        = string
}

variable "application_name" {
  description = "Name of the application that contains the version to be deployed"
  type        = string
}

variable "cname_prefix" {
  description = "Prefix to use for the fully qualified DNS name of the Environment."
  type        = string
  default     = null
}

variable "description" {
  description = "Short description of the Environment"
  type        = string
  default     = null
}

variable "tier" {
  description = " Elastic Beanstalk Environment tier. Valid values are Worker or WebServer. If tier is left blank WebServer will be used."
  type        = string
  default     = null

  validation {
    condition     = var.tier != null ? contains(["Worker", "WebServer"], var.tier) : true
    error_message = "Error! enter a valid value for tier. Valid values are 'Worker', 'WebServer'."
  }
}

variable "settings" {
  description = "Option settings to configure the new Environment. These override specific values that are set as defaults."
  type = list(object({
    namespace = string
    name      = string
    value     = string
    resource  = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for li in var.settings : alltrue([for ki, vi in li : vi != "HasCoupledDatabase" if ki == "name"])])
    error_message = "Error! Please use db settings rds option to pass value for 'HasCoupledDatabase'"
  }

}

variable "alb_settings" {
  description = <<-DOC
  {
    alb_certificate_arn      : ARN of the default SSL server certificate.
    elb_logs_s3_bucket_name  : S3 bucket name to store alb logs.
    elb_subnets              : The IDs of the subnet or subnets for the elastic load balancer. If you have multiple subnets, specify the value as a single comma-separated string of subnet IDs.
  }
  DOC

  type = object({
    alb_certificate_arn     = string
    elb_logs_s3_bucket_name = string
    elb_subnets             = list(string)
  })

}

variable "asg_settings" {
  description = <<-DOC
  {
    vpcid              : The ID of the VPC.
    asg_subnets        : The IDs of the Auto Scaling group subnet or subnets. If you have multiple subnets, specify the value as a single comma-separated string of subnet IDs.
  }
  DOC

  type = object({
    vpcid       = string
    asg_subnets = list(string)
  })

}

variable "solution_stack_name" {
  description = "A solution stack to base your environment."
  type        = string
  default     = null
}

variable "template_name" {
  description = "The name of the Elastic Beanstalk Configuration template to use in deployment."
  type        = string
  default     = null
}

variable "platform_arn" {
  description = "The ARN of the Elastic Beanstalk Platform to use in deployment."
  type        = string
  default     = null
}

variable "wait_for_ready_timeout" {
  description = "The maximum duration that Terraform should wait for an Elastic Beanstalk Environment to be in a ready state before timing out."
  type        = string
  default     = "20m"
}

variable "poll_interval" {
  description = "The time between polling the AWS API to check if changes have been applied."
  type        = number
  default     = null

  validation {
    condition     = var.poll_interval != null ? (var.poll_interval >= 10 && var.poll_interval <= 180) : true
    error_message = "Error! enter a valid value for poll_interval. Valid values are between 10 and 120."
  }
}

variable "version_label" {
  description = "The name of the Elastic Beanstalk Application Version to use in deployment."
  type        = string
  default     = null
}

variable "db_settings" {
  description = <<-DOC
  {
    engine                                      : The name of the database engine to use for this instance.
    version                                     : The version number of the database engine.
    vpc_subnets                                 : The IDs for your Amazon VPC.
    rds                                         : Specifies whether a DB instance is coupled to your environment. If toggled to true, Elastic Beanstalk creates a new DB instance coupled to your environment. If toggled to false, Elastic Beanstalk initiates decoupling of the DB instance from your environment.
    secretsmanager_db_password_secret_name      : Enter the name of secrets manager for db_password.
  }
  DOC

  type = object({
    engine                                 = string
    version                                = string
    vpc_subnets                            = list(string)
    rds                                    = bool
    secretsmanager_db_password_secret_name = string
  })

  default = {
    engine                                 = "mysql"
    version                                = "8.0.36"
    vpc_subnets                            = null
    rds                                    = false
    secretsmanager_db_password_secret_name = null
  }

  validation {
    condition     = contains(["mysql", "oracle-se1", "sqlserver-ex", "sqlserver-web", "sqlserver-se", "postgres"], var.db_settings.engine)
    error_message = "Error! Valid values for engine are mysql,oracle-se1,sqlserver-ex,sqlserver-web,sqlserver-se and postgres"
  }

  validation {
    condition     = var.db_settings.rds == true ? var.db_settings.vpc_subnets != null : true
    error_message = "Error! Please provide vpc subnets for database!"
  }

}

variable "tags" {
  description = "A set of tags to apply to the Environment. If configured with a provider"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}