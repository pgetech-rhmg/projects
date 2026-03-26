#Variables for transfer family server
variable "domain" {
  description = "The domain of the storage system that is used for file transfers. Valid values are: S3 and EFS. The default value is S3."
  type        = string
  default     = "S3"

  validation {
    condition     = contains(["S3", "EFS"], var.domain)
    error_message = "Error! enter a valid value for domain."
  }
}

variable "endpoint" {
  description = <<-DOC
    endpoint_type:
       The type of endpoint that you want your SFTP server connect to. If you connect to a VPC (or VPC_ENDPOINT), your SFTP server isn't accessible over the public internet.
    address_allocation_ids:
      A list of address allocation IDs that are required to attach an Elastic IP address to your SFTP server's endpoint. This property can only be used when endpoint_type is set to VPC.
    security_group_ids:
      A list of security groups IDs that are available to attach to your server's endpoint. If no security groups are specified, the VPC's default security groups are automatically assigned to your endpoint. This property can only be used when endpoint_type is set to VPC.
    subnet_ids:
      A list of subnet IDs that are required to host your SFTP server endpoint in your VPC. This property can only be used when endpoint_type is set to VPC.
    vpc_endpoint_id:
      The ID of the VPC endpoint. This property can only be used when endpoint_type is set to VPC_ENDPOINT.
    vpc_id:
      The VPC ID of the virtual private cloud in which the SFTP server's endpoint will be hosted. This property can only be used when endpoint_type is set to VPC.
  DOC

  type = object({
    endpoint_type          = string
    address_allocation_ids = optional(list(string))
    security_group_ids     = optional(list(string))
    subnet_ids             = optional(list(string))
    vpc_id                 = optional(string)
    vpc_endpoint_id        = optional(string)
  })
  validation {
    condition     = contains(["VPC", "VPC_ENDPOINT"], var.endpoint.endpoint_type)
    error_message = "Error! enter a valid value for endpoint type."
  }
  validation {
    condition     = var.endpoint.endpoint_type == "VPC" ? ((var.endpoint.vpc_id != null) && (var.endpoint.vpc_endpoint_id == null) && (length(var.endpoint.security_group_ids) > 0) && (length(var.endpoint.subnet_ids) > 0)) : true
    error_message = "Error! provide the appropriate error message with requirements for endpoint type VPC."
  }
  validation {
    condition     = var.endpoint.endpoint_type == "VPC_ENDPOINT" ? ((var.endpoint.vpc_id == null) && (var.endpoint.vpc_endpoint_id != null) && (length(var.endpoint.address_allocation_ids) == 0) && (length(var.endpoint.security_group_ids) == 0) && (length(var.endpoint.subnet_ids) == 0)) : true
    error_message = "Error! provide the appropriate error message with requirements for endpoint type VPC_ENDPOINT."
  }
}

variable "host_key" {
  description = "RSA private key."
  type        = string
  default     = null
}

variable "directory_id" {
  description = "The directory service ID of the directory service you want to connect to with an identity_provider_type of AWS_DIRECTORY_SERVICE."
  type        = string
}

variable "logging_role" {
  description = "Amazon Resource Name (ARN) of an IAM role that allows the service to write your SFTP users’ activity to your Amazon CloudWatch logs for monitoring and auditing purposes."
  type        = string
  default     = null
}

variable "post_authentication_login_banner" {
  description = "Specify a string to display when users connect to a server. This string is displayed after the user authenticates. The SFTP protocol does not support post-authentication display banners."
  type        = string
  default     = null
}

variable "pre_authentication_login_banner" {
  description = "Specify a string to display when users connect to a server. This string is displayed before the user authenticates."
  type        = string
  default     = null
}

variable "security_policy_name" {
  description = "Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, TransferSecurityPolicy-FIPS-2020-06 and TransferSecurityPolicy-2022-03. Default value is: TransferSecurityPolicy-2018-11."
  type        = string
  default     = "TransferSecurityPolicy-2018-11"

  validation {
    condition     = contains(["TransferSecurityPolicy-2018-11", "TransferSecurityPolicy-2020-06", "TransferSecurityPolicy-FIPS-2020-06", "TransferSecurityPolicy-2022-03"], var.security_policy_name)
    error_message = "Error! enter a valid value for security policy name."
  }
}

variable "workflow" {
  description = <<-DOC
    execution_role:
       Includes the necessary permissions for S3, EFS, and Lambda operations that Transfer can assume, so that all workflow steps can operate on the required resources.
    workflow_id:
      A unique identifier for the workflow.
  DOC

  type = object({
    execution_role = string
    workflow_id    = string
  })

  default = {
    execution_role = null
    workflow_id    = null
  }
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resource tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
