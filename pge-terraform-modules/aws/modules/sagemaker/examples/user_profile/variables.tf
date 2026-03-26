variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
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

#Variables for IAM
variable "user_profile_role_service" {
  description = "AWS service of the IAM role"
  type        = list(string)
}

#Variables for user_profile
variable "name" {
  description = "The name for the User Profile."
  type        = string
}

variable "domain_id" {
  description = "The ID of the associated Domain."
  type        = string
}

variable "notebook_output_option" {
  description = "Whether to include the notebook cell output when sharing the notebook. The default is Disabled. Valid values are Allowed and Disabled."
  type        = string
}

variable "jupyter_server_app_settings_instance_type" {
  description = "The instance type that the image version runs on.For valid values see SageMaker Instance Types."
  type        = string
}

variable "tensor_board_app_settings_instance_type" {
  description = "The instance type that the image version runs on.For valid values see SageMaker Instance Types."
  type        = string
}

variable "kernel_gateway_app_settings_instance_type" {
  description = "The instance type that the image version runs on.For valid values see SageMaker Instance Types."
  type        = string
}

#Variables for studio_lifecycle_config
variable "studio_lifecycle_config_app_type" {
  description = "The App type that the Lifecycle Configuration is attached to. Valid values are JupyterServer and KernelGateway."
  type        = string
}

variable "studio_lifecycle_config_content" {
  description = "The content of your Studio Lifecycle Configuration script. This content must be base64 encoded."
  type        = string
}