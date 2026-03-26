variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "kms_role" {
  type        = string
  description = "KMS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}
variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume"
}

variable "aws_r53_region" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number, mandatory"
}

################################################

#variables for Tags
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
################################################################

#variables for Cloudfront


variable "bucket_name" {
  description = "S3 bucket name. A unique identifier."
  type        = string
}

variable "static_content" {
  description = "The static content (html, css, etc) to include in the s3 bucket."
  type = string
}

variable "custom_domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
}

variable "grants" {
  description = "Map containing configuration."
  type        = any # map(string)
  default     = {}
}

variable "object_lock_configuration" {
  description = "Map containing static web-site configuration."
  type        = any # map(string)
  default     = {}
}

variable "cors_rule_inputs" {
  description = "Map containing static web-site cors configuration."
  type        = any # map(string)
  default     = {}
}

#variables for kms_key
variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console"
}

variable "kms_template_file_name" {
  description = "Policy template file in json format "
  type        = string
  default     = ""
}

variable "geo_restriction" {
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist)"
  type        = any
}

#################################################################


#variables for Lambda_function

variable "function_name" {
  description = "Unique name for your Lambda Function"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
}

variable "description" {
  description = "Description of what your Lambda Function does"
  type        = string
}

variable "runtime" {
  description = " Identifier of the function's runtime"
  type        = string
}

variable "local_zip_source_directory" {
  description = "Package entire contents of this directory into the archive"
  type        = string
}



#variables for aws_lambda_iam_role
variable "iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "policy_arns_list" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
  default     = []
}

variable "lambda_policy_name" {
  description = "The name of the policy"
  type        = string
}

variable "lambda_policy_path" {
  description = "The path of the policy in IAM"
  type        = string
  default     = "/"
}

variable "lambda_policy_description" {
  description = "The description of the policy"
  type        = string
  default     = ""
}