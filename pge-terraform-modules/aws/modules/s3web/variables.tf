variable "bucket_name" {
  description = "S3 bucket name. A unique identifier."
  default     = null
  type        = string
}

variable "s3_log_bucket" {
  description = "S3 bucket ARN for S3 logs. A unique identifier."
  default     = null
  type        = string
}

variable "s3_log_prefix" {
  description = "S3 bucket prefix for S3 logs. A unique identifier."
  default     = null
  type        = string
}

variable "cf_log_bucket" {
  description = "S3 bucket name for CloudFront logs. A unique identifier."
  default     = null
  type        = string
}

variable "cf_log_prefix" {
  description = "S3 bucket prefix for CloudFront logs. A unique identifier."
  default     = null
  type        = string
}

variable "waf_log_bucket" {
  description = "S3 bucket name for WAF logs. A unique identifier."
  default     = null
  type        = string
}

variable "versioning" {
  type        = string
  default     = "Disabled"
  description = "Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from Terraform state if the associated S3 bucket is unversioned."
}

variable "custom_domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
}

variable "subject_alternative_names" {
  description = "A set of domains the should be SANs in the issued certificate."
  type        = list(string)
  default     = []
}

variable "grants" {
  description = "Map containing configuration."
  type        = any # map(string)
  default = [
    {
      id          = null
      type        = "Group"
      permissions = ["READ"]
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
    {
      id          = null
      type        = "Group"
      permissions = ["WRITE"]
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
  ]
}


variable "object_lock_configuration" {
  description = "Map containing static web-site configuration."
  type        = any # map(string)
  default     = null
}


variable "cors_rule_inputs" {
  description = "Map containing static web-site cors configuration."
  type        = any # map(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key arn for S3 bucket and codepipeline encryption"
  type        = string
  default     = null
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

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
}

# validate the tags passed
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "default_root_object" {
  description = "default root object for cloudfront"
  type        = string
  default     = "index.html"
}

variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
  default     = null
}

variable "environment_variables_codescan_stage" {
  description = "Provide the list of environment variables required for codescan stage"
  type        = list(any)
  default     = []
}

variable "environment_variables_codepublish_stage" {
  description = "Provide the list of environment variables required for codepublish stage"
  type        = list(any)
  default     = []
}

variable "environment_variables_codebuild_stage" {
  description = "Provide the list of environment variables required for codebuild stage"
  type        = list(any)
  default     = []
}
variable "package_manager" {
  description = "Valid values for package manager are (npm, yarn)"
  type        = string
  default     = "npm"

  validation {
    condition     = contains(["npm", "yarn"], var.package_manager)
    error_message = "Valid values for package manager are (npm, yarn). Please select on these as package_manager parameter."
  }
}

#####
variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
  default     = "/vpc/id"
}

variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id_1 stored in ssm parameter"
  type        = string
  default     = "/vpc/privatesubnet1/id"
}

variable "ssm_parameter_subnet_id2" {
  description = "enter the value of subnet id_2 stored in ssm parameter"
  type        = string
  default     = "/vpc/privatesubnet2/id"
}

variable "ssm_parameter_subnet_id3" {
  description = "enter the value of subnet id_3 stored in ssm parameter"
  type        = string
  default     = "/vpc/privatesubnet3/id"
}

variable "secretsmanager_github_token" {
  description = "Secret manager path of the github OAUTH or PAT.  Example:  'github:token'"
  type        = string
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the name of jfrog artifactory token stored in secrets manager"
  type        = string
  default     = "jfrog:token"
}

variable "ssm_parameter_artifactory_host" {
  description = "Enter the name of jfrog artifactory host stored in ssm parameter"
  type        = string
  default     = "/jfrog/host"
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
  type        = string
  default     = "jfrog:user"
}

variable "ssm_parameter_artifactory_repo_key" {
  description = "Enter the name of JFrog npm Artifactory repo key to use in Terraform CodePipeline to pull the npm dependencies"
  type        = string
  default     = "/jfrog/repo_key"
}

variable "nodejs_version" {
  description = "Enter the nodejs version value"
  type        = string
  default     = "18"
}

variable "github_repo_url" {
  description = "Enter the github repo url for environment variable used in buildspec yml"
  type        = string
}

variable "pollchanges" {
  description = "Periodically check the location of your source content and run the pipeline if changes are detected, this uses Codepipeline Polling. default to false to use webhook"
  type        = string
  default     = "false"
}

variable "secretsmanager_sonar_token" {
  description = "Enter the token value of SonarQube stored in secrets manager"
  type        = string
  default     = "sonar:token"
}

variable "ssm_parameter_sonar_host" {
  description = "Enter the host value of SonarQube stored in ssm parameter"
  type        = string
  default     = "/sonar/host"
}

variable "github_branch" {
  description = "Enter the value of github repo branch"
  type        = string
}

variable "project_name" {
  description = "The display name visible in SonarQube dashboard. Example: My Project"
  type        = string
}

variable "project_key" {
  description = "A unique identifier of your project inside SonarQube"
  type        = string
}

variable "project_unit_test_dir" {
  description = "Enter the name of project unit test directory"
  type        = string
  default     = "."
}

variable "project_root_directory" {
  description = "Enter the project root directory value stored in ssm paramter"
  type        = string
  default     = "."
}

#variables for security_group_project
variable "cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
}

variable "sg_name" {
  description = "name of the security group"
  type        = string
  default     = null
}

variable "sg_description" {
  description = "vpc id for security group"
  type        = string
  default     = null
}

variable "s3web_type" {
  description = "Valid values for s3web type are (html, angular, react, custom)"
  type        = string
  default     = "html"

  validation {
    condition     = contains(["html", "angular", "react", "custom"], var.s3web_type)
    error_message = "Valid values for s3web type are (html, angular, react, custom). Please select on these as s3web_type parameter."
  }
}

variable "s3web_cmk_enabled" {
  description = "is s3web using kms cmk ?"
  type        = bool
  default     = false
}

variable "origin_ssl_protocols" {
  type        = list(string)
  default     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
  description = "The SSL/TLS protocols that you want CloudFront to use when communicating with your origin over HTTPS."
}

# Variables for resource 'aws_wafv2_ip_set'

variable "wafv2_ip_set_name" {
  description = "IP set name."
  type        = string
  default     = null
}

variable "wafv2_ip_set_description" {
  description = "A description of the IP set"
  type        = string
  default     = "AWS WAF PGE SourceIP Rule Set"
}


variable "advanced_aws_shield_protection" {
  description = "Allow PGE networks in WAF"
  type        = bool
  default     = false
}

variable "s3web_pge_waf" {
  description = "WAF type: Valid values are 'internal', 'external'"
  type        = string
  default     = "internal"
  validation {
    condition     = contains(["internal", "external"], var.s3web_pge_waf)
    error_message = "Valid values are 'internal', 'external'"
  }
}

variable "ssm_parameter_external_waf_name" {
  description = "Enter the parameter store path for the external WAF Name to use in cloudfront"
  type        = string
  default     = "/waf/external_waf_name"
}

variable "build_args1" {
  description = "Provide the build environment variables required for codebuild"
  type        = string
  default     = ""
}

variable "nodejs_version_codescan" {
  description = "Enter the nodejs version value for codescan, Minimum of node18 version is required to run sonarscan. Latest LTS is 20 which is recommended"
  type        = string
  default     = "20"
  validation {
    condition     = can(regex("(1[8-9]|[2-9][0-9])", var.nodejs_version_codescan))
    error_message = "Minimum of node18 version is required to run sonarscan."
  }
}

variable "custom_error_handlers" {
  type = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = number
  }))
  description = "List of cloudfront custom error response handlers"
  default     = []
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

variable "function_association" {
  description = "A config block that triggers a cloudfront function with specific actions"
  type        = any
  default     = []
}

### cloudfront function

variable "cf_function_name" {
  description = "Unique name for your CloudFront Function"
  type        = string
  default     = null
}

variable "cf_function_code" {
  description = "Source code of the function"
  type        = string
  default     = null
}

variable "cf_function_comment" {
  description = "Comment for cloudfront function"
  type        = string
  default     = null
}

variable "cf_function_publish" {
  description = "Whether to publish creation/change as Live CloudFront Function Version."
  type        = bool
  default     = false
}


variable "cf_function_runtime" {
  description = "The runtime environment for the CloudFront function"
  type        = string
  default     = "cloudfront-js-1.0"

}

variable "existing_cloudfront_distribution_arn" {
  description = "ARN of an existing CloudFront distribution to use instead of creating a new one. If provided, the module will not create a new CloudFront distribution."
  type        = string
  default     = null
}

variable "create_route53_records" {
  description = "Whether to create Route53 records for the custom domain. Set to false when using F5 or other external routing mechanisms."
  type        = bool
  default     = true
}


