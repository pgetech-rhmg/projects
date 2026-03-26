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
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "name" {
  description = "Name of the project which will be used as a prefix for every resource."
  type        = string
  default     = "imagebuilder-linux-example"
}

variable "vpc_cidr" {
  description = "Cidr block for the VPC"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the resource need to be created"
  type        = string
}

variable "build_version" {
  description = "Build Version"
  type        = string
}

variable "test_version" {
  description = "Test Version"
  type        = string
  default     = "0.0.1"
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "private_subnet" {
  description = "Private Subnets"
  type        = string
  default     = "subnet-0c02015de7dc8232c"
}

variable "parent_image_ssm_path" {
  description = "Parent Image."
  type        = string
}

variable "recipe_version" {
  description = "Image Builder Recipe Version."
  type        = string
  default     = "0.0.1"
}

variable "ec2_imagebuilder_instance_type" {
  description = "EC2 Image Builder instance type"
  type        = list(string)
  default     = ["m5.large"]
}

variable "delete_on_termination_img_recipe" {
  description = "Delete on Termination of Image Recipe."
  type        = bool
}

variable "image_tests_enabled" {
  description = "Whether to enable the image tests in the image builder image."
  type        = bool
  default     = true
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "pipeline_status" {
  description = "Pipeline status whether to ENABLED OR DISABLED"
  type        = string
}

variable "platform" {
  description = "Specify the Platform whether Windows, Linux, MacOS"
  type        = string
}

variable "uninstall_after_build" {
  description = "Whether to uninstall the system manager agent after the image is built."
  type        = bool
  default     = false
}

variable "recipe_description" {
  description = "Description of Image Builder Image Recipe"
  type        = string
  default     = "This is the Linux Image Builder Recipe"
}

variable "block_device_iops" {
  description = "Provisioned IOPS for the block device (only for io1 or io2 types)"
  type        = number
  default     = null
}

variable "execution_role" {
  description = "ARN of the service linked role for image builder"
  type        = string
  default     = null
}

variable "ami_name" {
  description = "Name of AMI"
  type        = string
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

variable "force_destroy_s3_bucket" {
  description = "Whether to destroy the S3 bucket while destroying other resources"
  type        = bool
}

variable "log_policy" {
  description = "Policy for S3 bucket"
  type        = string
}

variable "bucket_name" {
  description = "Imagebuilder logs S3 bucket name"
  type        = string
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

variable "notification_email" {
  description = "Email address to receive notifications"
  type        = list(string)
}
# Variable for the SSM Document Name
variable "ssm_document_name" {
  description = "SSM Document Name"
  default     = "release-linux-ami-nonprod"
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
# variable for ARN od AWS provide component
variable "aws_owned_component_arn" {
  description = "ARN of AWS provide component"
  type        = list(string)
  default     = []

}
variable "distribution_regions" {
  description = "List of regions where the image should be distributed"
  type        = list(string)
  #default = [ "us-east-1", "us-west-1" ]

}
variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}
variable "ami_parameter_store_status" {
  description = "Status of AMI parameter store"
  type        = string


}