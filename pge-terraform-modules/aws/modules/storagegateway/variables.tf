# variables for file_storagegateway
variable "gateway_name" {
  description = "Name of the gateway."
  type        = string
}

variable "gateway_timezone" {
  description = "Time zone for the gateway. The time zone is of the format 'GMT', 'GMT-hr:mm', or 'GMT+hr:mm'. For example, GMT-4:00 indicates the time is 4 hours behind GMT. The time zone is used, for example, for scheduling snapshots and your gateway's maintenance schedule."
  type        = string
  validation {
    condition     = can(regex("^GMT", var.gateway_timezone))
    error_message = "Error! Invalid timezone format, valid formats are 'GMT', 'GMT-hr:mm, or 'GMT+hr:mm'."
  }
}

variable "activation_gateway" {
  description = <<-DOC
   activation_key
       Gateway activation key during resource creation.
   gateway_ip_address
       Gateway IP address to retrieve activation key during resource creation. Conflicts with activation_key. Gateway must be accessible on port 80 from where Terraform is running.
  DOC
  type = object({
    activation_key     = string
    gateway_ip_address = string
  })

  default = {
    activation_key     = null
    gateway_ip_address = null
  }
  validation {
    condition     = var.activation_gateway.activation_key != null && var.activation_gateway.gateway_ip_address == null || var.activation_gateway.activation_key == null && var.activation_gateway.gateway_ip_address != null ? true : false
    error_message = "Error! gateway need either activation_key or gateway_ip_address."
  }
}

variable "gateway_type" {
  description = "Type of the gateway. The default value is STORED."
  type        = string
  default     = null
  validation {
    condition     = contains(["FILE_FSX_SMB", "FILE_S3"], var.gateway_type)
    error_message = "Error! Invalid storage type. Valid values are FILE_FSX_SMB and FILE_S3."
  }
}

variable "gateway_vpc_endpoint" {
  description = "VPC endpoint address to be used when activating your gateway. This should be used when your instance is in a private subnet. Requires HTTP access from client computer running terraform."
  type        = string
  validation {
    condition     = can(regex("^vpce-*", var.gateway_vpc_endpoint))
    error_message = "Error! provide valid vpc endpoint."
  }
}

variable "cloudwatch_log_group_arn" {
  description = "The Amazon Resource Name (ARN) of the Amazon CloudWatch log group to use to monitor and log events in the gateway."
  type        = string
  validation {
    condition     = can(regex("arn:aws:logs:[a-z][a-z]-[a-z]+-[1-9]+:[0-9]{12}:log-group:*", var.cloudwatch_log_group_arn))
    error_message = "Error! Enter a valid audit_destination_arn and log group name should begin with /aws/vendedlogs/.."
  }
}

variable "smb_security_strategy" {
  description = "Specifies the type of security strategy. Valid values are: ClientSpecified, MandatorySigning, and MandatoryEncryption."
  type        = string
  default     = "ClientSpecified"
  validation {
    condition     = contains(["ClientSpecified", "MandatorySigning", "MandatoryEncryption"], var.smb_security_strategy)
    error_message = "Error! Invalid smb security strategy. Valid values are: ClientSpecified, MandatorySigning, and MandatoryEncryption."
  }
}

variable "smb_file_share_visibility" {
  description = "Specifies whether the shares on this gateway appear when listing shares."
  type        = bool
  default     = false
}

variable "maintenance_start_time" {

  description = <<-_EOT
    {
    maintenance_start_time : "The gateway's weekly maintenance start time information, including day and time of the week. The maintenance time is the time in your gateway's time zone."
    day_of_month           : (Optional) The day of the month component of the maintenance start time represented as an ordinal number from 1 to 28, where 1 represents the first day of the month and 28 represents the last day of the month.
    day_of_week            : (Optional) The day of the week component of the maintenance start time week represented as an ordinal number from 0 to 6, where 0 represents Sunday and 6 Saturday.
    hour_of_day            : (Required) The hour component of the maintenance start time represented as hh, where hh is the hour (00 to 23). The hour of the day is in the time zone of the gateway.
    minute_of_hour         : (Required) The minute component of the maintenance start time represented as mm, where mm is the minute (00 to 59). The minute of the hour is in the time zone of the gateway.
    }
    _EOT

  type = object({
    day_of_month   = optional(number)
    day_of_week    = optional(number)
    hour_of_day    = number
    minute_of_hour = number
  })

  default = ({
    day_of_month   = null
    day_of_week    = null
    hour_of_day    = null
    minute_of_hour = null
  })

  validation {
    condition     = var.maintenance_start_time.day_of_month != null ? var.maintenance_start_time.day_of_month >= 1 && var.maintenance_start_time.day_of_month <= 28 : true
    error_message = "Error! valid values for day_of_month are between 1 to 28."
  }
  validation {
    condition     = var.maintenance_start_time.day_of_week != null ? var.maintenance_start_time.day_of_week >= 0 && var.maintenance_start_time.day_of_week <= 6 : true
    error_message = "Error! valid values for day_of_month are between 0 to 6."
  }
  validation {
    condition     = var.maintenance_start_time.hour_of_day != null ? var.maintenance_start_time.hour_of_day >= 00 && var.maintenance_start_time.hour_of_day <= 23 : true
    error_message = "Error! valid values for day_of_month are between 00 to 23."
  }
  validation {
    condition     = var.maintenance_start_time.minute_of_hour != null ? var.maintenance_start_time.minute_of_hour >= 00 && var.maintenance_start_time.minute_of_hour <= 59 : true
    error_message = "Error! valid values for day_of_month are between 00 to 59."
  }
}

variable "smb_active_directory_settings" {
  description = <<-_EOT
    {
    smb_active_directory_settings : "Nested argument with Active Directory domain join information for Server Message Block (SMB) file shares. Only valid for FILE_S3 and FILE_FSX_SMB gateway types. Must be set before creating ActiveDirectory authentication SMB file shares."
    domain_name         : (Required) The name of the domain that you want the gateway to join.
    password            : (Required) The password of the user who has permission to add the gateway to the Active Directory domain.
    username            : (Required) The user name of user who has permission to add the gateway to the Active Directory domain.
    timeout_in_seconds  : (Optional) Specifies the time in seconds, in which the JoinDomain operation must complete. The default is 20 seconds.
    organizational_unit : (Optional) The organizational unit (OU) is a container in an Active Directory that can hold users, groups, computers, and other OUs and this parameter specifies the OU that the gateway will join within the AD domain.
    domain_controllers  : (Optional) List of IPv4 addresses, NetBIOS names, or host names of your domain server. If you need to specify the port number include it after the colon (“:”). For example, mydc.mydomain.com:389.
    }
    _EOT

  type = object({
    domain_name         = string
    password            = string
    username            = string
    timeout_in_seconds  = optional(number)
    organizational_unit = optional(string)
    domain_controllers  = optional(list(string))
  })

  default = ({
    domain_name         = null
    password            = null
    username            = null
    timeout_in_seconds  = null
    organizational_unit = null
    domain_controllers  = null
  })

  validation {
    condition     = var.smb_active_directory_settings.timeout_in_seconds != null ? var.smb_active_directory_settings.timeout_in_seconds >= 0 && var.smb_active_directory_settings.timeout_in_seconds <= 3600 : true
    error_message = "Error! valid values for timeout_in_seconds are between 0 to 3600."
  }
  validation {
    condition     = var.smb_active_directory_settings.domain_name != null ? can(regex("^([a-zA-Z0-9]+[\\.-])+([a-zA-Z0-9])+$", var.smb_active_directory_settings.domain_name)) : true
    error_message = "Error! valid values for domain_name like mydomain.com."
  }
}

variable "timeout_create" {
  description = "Timeout for Creating file system"
  type        = string
  default     = "10m"
  validation {
    condition     = can(regex("^[[:digit:]]+m$", var.timeout_create))
    error_message = "Error! enter valid input for timeout_create. Valid input should end with m. (eg : 20m)."
  }
}

# variables for tags
variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}