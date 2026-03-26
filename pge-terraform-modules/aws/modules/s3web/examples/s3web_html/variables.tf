variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "aws_r53_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "kms_name" {
  description = "Name of the KMS key."
  type        = string
}

variable "kms_description" {
  description = "Description of the KMS key."
  type        = string
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "account_num_r53" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "versioning" {
  type        = string
  default     = "Disabled"
  description = "Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from Terraform state if the associated S3 bucket is unversioned."
}

variable "project_name" {
  description = "The display name visible in SonarQube dashboard. Example: My Project"
  type        = string
}

variable "project_key" {
  description = "A unique identifier of your project inside SonarQube"
  type        = string
}

variable "object_lock_configuration" {
  type        = any
  default     = null
  description = "With S3 Object Lock, you can store objects using a write-once-read-many (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely."

}

variable "cloudfront_priceclass" {
  description = "Choosing the price class for a CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_priceclass)
    error_message = "Valid values for cloudfront price class type are PriceClass_100, PriceClass_200 and PriceClass_All"
  }
}

variable "secretsmanager_artifactory_user" {
  description = "secret manager path of the artifactory user"
  type        = string
}

variable "secretsmanager_artifactory_token" {
  description = "secret manager path of the artifactory user token"
  type        = string
}

variable "secretsmanager_sonar_token" {
  description = "Enter the token value of SonarQube stored in secrets manager"
  type        = string
}



########################################################
########### Tags #######################################
########################################################
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."

  validation {
    condition     = contains(["Dev", "Test", "QA", "Prod"], var.Environment)
    error_message = "Valid values for Environment are (Dev, Test, QA, Prod). Please select on these as Environment parameter."
  }
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted", "Privileged"], var.DataClassification)
    error_message = "Valid values for DataClassification are (Public, Internal, Confidential, Restricted, Privileged). Please select on these as DataClassification parameter."
  }
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"

  validation {
    condition = alltrue([
      for alias in var.Compliance : contains(["SOX", "HIPAA", "CCPA", "None"], alias)
    ])
    error_message = "Valid values for DataClassification are SOX, HIPAA, CCPA or None. Please select on these as Compliance parameter."
  }
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"

  validation {
    condition     = contains(["High", "Medium", "Low"], var.CRIS)
    error_message = "Valid values for Cyber Risk Impact Score are High, Medium, Low (only one). Please select one these CRIS values."
  }
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."

  validation {
    condition = alltrue([
      for aliases in var.Notify : can(regex("^\\w+([\\.-]?\\w+)*@([\\.-]?\\w+)*(\\.\\w{2,3})+$", aliases))
    ])
    error_message = "Invalid Email Address for Notify tag."
  }

}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  validation {
    condition     = length(var.Owner) == 3
    error_message = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg."
  }
}

############################

variable "secretsmanager_github_token" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
}



variable "build_args1" {
  description = "Provide the list of build environment variables required for codebuild"
  type        = string
  default     = ""
}


variable "bucket_name_html" {
  description = "S3 bucket name. A unique identifier."
  type        = string
  default     = null
}

variable "custom_domain_name_html" {
  description = "A domain name for which the certificate should be issued"
  type        = string
}

variable "github_repo_url_html" {
  description = "Enter the github repo url for environment variable used in buildspec yml"
  type        = string
}

variable "github_branch_html" {
  description = "Enter the value of github repo branch"
  type        = string
}

variable "project_name_html" {
  description = "The display name visible in SonarQube dashboard. Example: My Project"
  type        = string
}

variable "project_key_html" {
  description = "A unique identifier of your project inside SonarQube"
  type        = string
}

variable "s3web_type_html" {
  description = "vpc id for security group"
  type        = string
  validation {
    condition     = contains(["html", "angular", "react", "custom"], var.s3web_type_html)
    error_message = "Valid values for s3web type are (html, angular, react, custom). Please select on these as s3web_type parameter."
  }
}

variable "ssm_parameter_artifactory_host" {
  description = "Enter the name of jfrog artifactory host stored in ssm parameter"
  type        = string
  default     = "/jfrog/host"

}

#cloudfront origin access control variables
variable "cloudfront_oac_name" {
  description = "A name that identifies the Origin Access Control."
  type        = string

}

variable "cloudfront_oac_description" {
  description = "The description of the Origin Access Control."
  type        = string
  default     = "Managed by Terraform"
}

variable "cloudfront_oac_origin_type" {
  description = "The type of origin for this Origin Access Control. Valid values: lambda, mediapackagev2, mediastore, s3."
  type        = string
  default     = "s3"
}

variable "cloudfront_oac_signing_behavior" {
  description = "Specifies which requests CloudFront signs. Allowed values: always, never, no-override."
  type        = string
  default     = "always"
}

variable "cloudfront_oac_signing_protocol" {
  description = "Determines how CloudFront signs requests. The only valid value is sigv4."
  type        = string
  default     = "sigv4"
}

variable "existing_cloudfront_distribution_arn" {
  description = "ARN of an existing CloudFront distribution to use instead of creating a new one. If provided, the module will not create a new CloudFront distribution. Example: 'arn:aws:cloudfront::123456789012:distribution/ABCD1234EFGH'"
  type        = string
  default     = null
}

variable "create_route53_records" {
  description = "Whether to create Route53 records for the custom domain. Set to false when using F5 or other external routing mechanisms."
  type        = bool
  default     = true
}

