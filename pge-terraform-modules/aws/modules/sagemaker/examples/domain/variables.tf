variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "kms_role" {
  description = "AWS KMS role to assume"
  type        = string
}
variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#variables for Tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  type        = string
}

variable "Notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "Owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

#Supporting Resource
variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id1 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "enter the value of subnet id2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "enter the value of subnet id3 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

#Variables for Domain
variable "name" {
  description = "The name of the domain."
  type        = string
}

variable "notebook_output_option" {
  description = "Whether to include the notebook cell output when sharing the notebook. The default is Disabled. Valid values are Allowed and Disabled."
  type        = string
}

variable "jupyter_server_app_settings_instance_type" {
  description = "The instance type that the image version runs on.. For valid values see SageMaker Instance Types."
  type        = string
}

variable "tensor_board_app_settings_instance_type" {
  description = "The instance type that the image version runs on.. For valid values see SageMaker Instance Types."
  type        = string
}

variable "kernel_gateway_app_settings_instance_type" {
  description = "The instance type that the image version runs on.. For valid values see SageMaker Instance Types."
  type        = string
}

variable "home_efs_file_system" {
  description = "The retention policy for data stored on an Amazon Elastic File System (EFS) volume. Valid values are Retain or Delete. Default value is Retain."
  type        = string
}

variable "jupyter_server_app_settings_lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource."
  type        = string
}

variable "jupyter_server_app_settings_lifecycle_config_arns" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configurations."
  type        = list(string)
}

variable "kernel_gateway_app_settings_lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource."
  type        = string
}

variable "kernel_gateway_app_settings_lifecycle_config_arns" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configurations."
  type        = list(string)
}

variable "tensor_board_app_settings_lifecycle_config_arn" {
  description = "The Amazon Resource Name (ARN) of the Lifecycle Configuration attached to the Resource."
  type        = string
}

#Variables for IAM
variable "domain_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

# Default Space Settings Variables
variable "default_space_execution_role" {
  description = "The execution role ARN for the default space settings. If not provided, will use the default_user_settings execution_role."
  type        = string
  default     = null
}

variable "default_space_security_groups" {
  description = "The security groups for the default space settings. If not provided, will use the default_user_settings security_groups."
  type        = list(string)
  default     = null
}

variable "default_space_jupyter_server_app_settings_instance_type" {
  description = "The instance type for JupyterServer app in default space settings. For valid values see SageMaker Instance Types."
  type        = string
  default     = null
}

variable "default_space_kernel_gateway_app_settings_instance_type" {
  description = "The instance type for KernelGateway app in default space settings. For valid values see SageMaker Instance Types."
  type        = string
  default     = null
}

variable "tag_propagation" {
  description = "Indicates whether custom tag propagation is supported for the domain. Valid values are 'ENABLED' or 'DISABLED'."
  type        = string
  default     = "DISABLED"
}
