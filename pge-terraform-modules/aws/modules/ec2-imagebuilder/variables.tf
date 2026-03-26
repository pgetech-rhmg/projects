variable "name" {
  description = "Name of the project which will be used as a prefix for every resource."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy the EC2 Image Builder Environment."
  type        = string
}

variable "vpc_cidr" {
  description = "Cidr block for the VPC"
  type        = string
}

variable "ec2_imagebuilder_instance_types" {
  description = "Instance type for EC2 instance used in the Imagebuilder."
  type        = list(string)
}

variable "instance_key_pair" {
  description = "EC2 key pair to add to the default user on the builder(In case existent EC2 Key Pair is provided)"
  type        = string
  default     = null
}

variable "create_security_group" {
  description = "(Optional) Create security group for EC2 Image Builder instances. Please note this security group will be created with default egress rule to 0.0.0.0/0 CIDR Block. In case you want to have a more restrict set of rules, please provide your own security group id on security_group_ids variable"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Custom Security group IDs for EC2 Image Builder instances(In case existent Security Group is provided)"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "Subnet id for launching the EC2 Image Builder instance"
  type        = string
}

variable "terminate_instance_on_failure" {
  description = "Whether to terminate the builder instance on build failure"
  type        = bool
}

variable "tags" {
  description = "Map of resource tags to associate with resource"
  type        = map(string)
}

variable "s3_bucket_name" {
  description = "The S3 bucket name for storing logs of the EC2 Image Builder."
  type        = string
}

variable "enhanced_image_metadata_enabled" {
  description = "Enable additional metadata collection of the AMI."
  type        = bool
  default     = true
}

variable "execution_role" {
  description = "ARN of the role for image builder execution."
  type        = string
}

variable "image_tests_enabled" {
  description = "Whether to enable the Image test configuration."
  type        = bool
}

variable "timeout_minutes" {
  description = "Timeout in minutes for image test"
  type        = number
  default     = 60
}

variable "timeout" {
  description = "Overall timeout for the image creation process in hours"
  type        = string
  default     = "2h"
}

variable "pipeline_status" {
  description = "Status of the pipeline whether to ENABLED or DISABLED"
  type        = string
}

variable "schedule_expression" {
  description = <<-EOD
  "(Optional) pipeline_execution_start_condition = The condition configures when the pipeline should trigger a new image build. 
  Valid Values: EXPRESSION_MATCH_ONLY | EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE
  scheduleExpression = The cron expression determines how often EC2 Image Builder evaluates your pipelineExecutionStartCondition.
  e.g.:  "cron(0 0 * * ? *)"
  EOD
  type = list(object({
    pipeline_execution_start_condition = string,
    scheduleExpression                 = string
  }))
  default = []
}

variable "recipe_version" {
  description = "Version of the image recipe in semantic format."
  type        = string
  default     = "0.0.2"
}

variable "parent_image_ssm_path" {
  description = "SSM path of the base AMI for the image recipe"
  type        = string
  default     = "pge-base-linux-ami"
}

variable "recipe_description" {
  description = "Image Recipe description."
  type        = string
}

variable "user_data_base64" {
  description = "Base64 encoded user data for execution during the build process."
  type        = string
  default     = null
}

variable "working_directory" {
  description = "Working directory for build and test workflows"
  type        = string
  default     = null
}

variable "recipe_volume_size" {
  description = "Size of the volume for image recipe"
  type        = number
  default     = 8
}

variable "recipe_volume_type" {
  description = "Type of the volume for image recipe"
  type        = string
  default     = "gp3"
}

variable "delete_on_termination_img_recipe" {
  description = "Whether to delete the volume on instance termination"
  type        = bool
}

variable "block_device_iops" {
  description = "Provisioned IOPS for the block device (only for io1 or io2 types)"
  type        = number
}

variable "block_device_throughput" {
  description = "Throughput in MiB/s for gp3 volumes only."
  type        = number
  default     = null
}


variable "change_description" {
  default     = null
  description = "description of changes since last version"
  type        = string

}
variable "component_version" {
  description = "version of the component"
  type        = string

}

variable "component_data" {
  description = "Map of component data that can either contain file path or data URI"
  type        = map(string)
  default     = {}

}
variable "aws_owned_component_arn" {
  description = "ARN of AWS provide component"
  type        = list(string)
  default     = []

}
variable "component_description" {
  default     = null
  description = "description of component"
  type        = string

}
variable "component_kms_key_id" {
  default     = null
  description = "KMS key to use for encryption"
  type        = string

}
variable "component_name" {
  description = "name to use for component"
  type        = string

}

variable "component_platform" {
  default     = "Linux"
  description = "platform of component(Linux or Windows)"
  type        = string

}
variable "component_supported_os_versions" {
  default     = null
  description = "Aset of operating system versions supported by the component. If the os information is available, a prefix match is performed against the base image os version during image recipe creation."
  type        = set(string)

}


variable "uninstall_after_build" {
  description = "Whether to uninstall the system manager agent after the image is built."
  type        = bool
}

variable "ami_regions_kms_key" {
  description = "Map of KMS key ARN for AMI encryption per region"
  type        = map(string)
  default     = {}
}

variable "imagebuilder_dist_description" {
  description = "Description of the distribution configuration"
  type        = string
  default     = null
}

variable "ami_name" {
  description = "Name format for distribution AMI. Use variables like {{imagebuilder:buildDate}} if required"
  type        = string
}

variable "ami_tags" {
  description = "Tags to apply for distributed AMI"
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  description = "ARN of KMS key used for encrypting the AMI"
  type        = string
  default     = null
}

variable "launch_permission_user_ids" {
  description = "List of AWS account ID's for AMI launch permissions."
  type        = list(string)
  default     = []
}

variable "receipients" {
  description = "Email ID of Receipient"
  type        = list(string)
  default     = []
}
variable "sender" {
  description = "Email ID of Sender"
  type        = string
}
variable "launch_permission_organization_arns" {
  description = "List of AWS organization ARNs for AMI launch permission"
  type        = list(string)
  default     = []
}

variable "launch_permission_organization_units_arn" {
  description = "List of Organizational ARNs for AMI launch permissions."
  type        = list(string)
  default     = []
}

variable "launch_template_id" {
  description = "The ID of EC2 launch template to associate with the AMI."
  type        = string
  default     = null
}

variable "notification_email" {
  description = "Email address to receive notifications"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region where the resource need to be created"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
# Variable for the SSM Document Name
variable "ssm_document_name" {
  description = "SSM Document Name"
  type        = string
}

# variable for the SSM Document Version 
variable "ssm_document_version" {
  description = " Version of the resources associated with the SSM Document"
  default     = "1"
  type        = string
}

# Variable for the Name of the Parameter store for the Golden AMI
variable "ami_parameter_store" {
  description = "Name of parameter store for the golden AMI"
  default     = "/ami/linux/golden"
  type        = string
}
# Variable for the StackSet name to distribute the golden AMI
variable "stack_set_name" {
  description = "Name od StackSet to distribute the golden AMI"
  default     = "current-ami-id-linux-prod"
  type        = string
}

# Variable for the NonProd AMI SNS topic ARN (Parameter store for the new AMI NonProd notifications)
variable "non_prod_ami_sns_topic_arn" { //get from SSM Param
  description = "Parameter store name for the new AMI NonProd notification topic ARN"
  type        = string
  default     = "/ami/linux/new-ami/nonprod/topic/arn"
}

# Variable for the CMK ARN for EBS image encryption (Parameter store)
variable "cmk_ebs_arn" { // get from SSM param
  description = "CMK ARN for EBS image encryption"
  default     = "/servicekey/ebs"
  type        = string
}

# Variable for the Image builder Approver SNS topic ARN
variable "approver_topic_arn" { // get from SSM Param
  description = "ARN of the Image builder approver SNS topic"
  default     = "/ami/base-linux/approver/topic/arn"
  type        = string
}

#Variable for the list of AWS authenticated principals eligible to aprove/reject the AMI distribution
variable "approver_arns" {
  description = "A list of AWS authenticated principals who are eligible to either approve or reject the AMI Distribution action."
  type        = list(string)
  default     = ["arn:aws:sts::686137062481:assumed-role/SuperAdmin/SCLF@utility.pge.com", "arn:aws:sts::686137062481:assumed-role/SuperAdmin/A2VB@utility.pge.com"]
}

# Variable for the dynamoDB table for target accounts
variable "target_accounts_table" {
  description = "DynamoDB table of target accounts"
  type        = string
}

#variable for the CMK ARN for Lambda environment encryption (parameter store)
variable "cmk_arn" {
  description = "Parameter store of the CMK ARN for Lambda environment encryption"
  type        = string
  default     = "/servicekey/lambda"
}
variable "subnet_id_az_a" { // gwt from SSM Param
  description = "SSM Parameter that holds the subnet for Availability Zone A"
  type        = string
  default     = "/vpc/2/privatesubnet1/id"
  validation {
    condition     = length(var.subnet_id_az_a) >= 1
    error_message = "The value of 'subnet_id_az_a' must be atleast 1 characters long."
  }
}
# Variable for the Subnet ID for Availability Zone B (Parameter store)
variable "subnet_id_az_b" { // get form SSM Param
  description = "SSM Parameter that holds the subnet for Availability Zone B"
  type        = string
  default     = "/vpc/2/privatesubnet2/id"
  validation {
    condition     = length(var.subnet_id_az_b) >= 1
    error_message = "The value of 'subnet_id_az_b' must be atleast 1 characters long."
  }
}
# Variable for the Subnet ID for Availability Zone C (PArameter store)
variable "subnet_id_az_c" { //get from SSM Param
  description = "SSM Parameter that holds the subnet for Availability Zone C"
  type        = string
  default     = "/vpc/2/privatesubnet3/id"
  validation {
    condition     = length(var.subnet_id_az_c) >= 1
    error_message = "The value of 'subnet_id_az_c' must be atleast 1 characters long."
  }
}
variable "license_configuration_arn" {
  description = "The ARN of the license configuration"
  type        = string
  default     = ""

}
variable "distribution_regions" {
  description = "List of regions where the image should be distributed"
  type        = list(string)
  #default = [ "us-east-1", "us-west-1" ]

}
variable "ami_parameter_store_status" {
  description = "Status of AMI parameter store"
  type        = string


}

