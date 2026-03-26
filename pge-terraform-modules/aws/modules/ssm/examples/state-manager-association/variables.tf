variable "account_num" {
  description = "Target AWS account number, mandatory. "
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume."
  type        = string
}


variable "aws_region" {
  description = "AWS region."
  type        = string
}

####################################################
# Variables for Tags
####################################################

#Variables forTag
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}


variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "optional_tags" {
  description = "optional_tags."
  type        = map(string)
  default     = {}
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}
#####
variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id_1 stored in ssm parameter"
  type        = string
}



# State manager Association variables

variable "ssm_association_name" {
  type        = string
  description = "SSM association name"
}

variable "schedule_expression" {
  type        = string
  description = "SSM association schedule expression"
}
###########################################################

#### S3 bucket ####

variable "document_bucket_name" {
  type        = string
  description = "s3 bucket for document"
}

variable "output_s3_key_prefix" {
  description = "The Amazon S3 bucket subfolder"
  type        = string
}


### KMS ###

variable "kms_key" {
  type        = string
  description = "The KMS key to encrypt data in store."
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}

### IAM role for SNS ###
variable "sns_iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "sns_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "snstopic_name" {
  description = "name of the SNS topic"
  type        = string
}

variable "snstopic_display_name" {
  description = "The display name of the SNS topic"
  type        = string
}

variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
}

### SSM Document


variable "ssm_document_name" {
  type        = string
  description = "SSM document name"
}

variable "ssm_document_type" {
  type        = string
  description = "The type of the document. Valid document types include: Automation, Command, Package, Policy, and Session"
}

variable "ssm_document_format" {
  type        = string
  description = "The format of the document. Valid document types include: JSON and YAML"
  validation {
    condition = anytrue([
      var.ssm_document_format == "JSON",
    var.ssm_document_format == "YAML"])
    error_message = "Valid values for ssm_document_format are JSON and YAML."
  }
}


### Lambda and IAM role for Lambda ###
variable "document_iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "document_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "lambda_function_name" {
  description = "Name of the Lambda role"
  type        = string
}

variable "lambda_iam_name" {
  description = "Name of the iam role"
  type        = string
}



variable "statemanager_s3_bucket" {
  description = "S3 bucket for SSM document parameter"
  type        = string
}

#vairables for codebuild security group
variable "cidr_egress_rules_codebuild" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}




####################################################
# Variables for Patch Baseline
####################################################

variable "operating_system" {
  description = "Defines the operating system the patch baseline applies to. Supported operating systems include WINDOWS, AMAZON_LINUX, AMAZON_LINUX_2, SUSE, UBUNTU, CENTOS, and REDHAT_ENTERPRISE_LINUX. The Default value is WINDOWS."
  type        = string
}

variable "ssm_patch_baseline_name" {
  type        = string
  description = "The name of the patch baseline"
}

variable "approved_patches_compliance_level" {
  type        = string
  description = "Defines the compliance level for approved patches. This means that if an approved patch is reported as missing, this is the severity of the compliance violation. Valid compliance levels include the following: CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL, UNSPECIFIED. The default value is UNSPECIFIED."
}

variable "patch_baseline_approval_rules" {
  description = "A set of rules used to include patches in the baseline. Up to 10 approval rules can be specified. Each `approval_rule` block requires the fields documented below."
  type        = list(any)
}

variable "set_default_patch_baseline" {
  description = "whether to set this baseline as a Default Patch Baseline"
  type        = bool
}

variable "patch_group_names" {
  description = "The targets to register with the maintenance window. In other words, the instances to run commands on when the maintenance window runs. You can specify targets using instance IDs, resource group names, or tags that have been applied to instances."
  type        = list(string)
}

variable "aws_org_id" {
  description = "The AWS ORG ID "
  type        = string
  default     = "o-7vgpdbu22o"

}

variable "max_concurrency" {
  type        = string
  description = "Input max_concurrency in either number or percentage"
  default     = "20%"

}

variable "apply_only_at_cron_interval" {
  description = "when you create a new or update associations, the system runs it immediately and then according to the schedule you specified. Enable this option if you do not want an association to run immediately after you create or update it. This parameter is not supported for rate expressions. Default: false."
  type        = bool
  default     = false
}