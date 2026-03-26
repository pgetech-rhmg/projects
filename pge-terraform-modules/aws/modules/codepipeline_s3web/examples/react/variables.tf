variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

# variable "kms_role" {
#   description = "AWS role to administer the KMS key."
#   type        = string
# }
# 
# variable "kms_description" {
#   type        = string
#   default     = "Parameter Store KMS master key"
#   description = "The description of the key as viewed in AWS console."
# }
# 
# variable "kms_name" {
#   type        = string
#   description = "KMS key name for customer managed key encryption"
# }

variable "build_args1" {
  description = "Provide the build environment variables required for codebuild"
  type        = string
  default     = ""
}


variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

#Variables for Tags
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
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
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

variable "ssm_parameter_subnet_id2" {
  description = "enter the value of subnet id_2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "enter the value of subnet id_3 stored in ssm parameter"
  type        = string
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the name of jfrog artifactory token stored in secrets manager"
  type        = string
}

variable "ssm_parameter_artifactory_host" {
  description = "Enter the name of jfrog artifactory host stored in ssm parameter"
  type        = string
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
  type        = string
}

variable "ssm_parameter_artifactory_repo_key" {
  description = "Enter the name of JFrog npm Artifactory repo key to use in Terraform CodePipeline to pull the npm dependencies"
  type        = string
}

variable "nodejs_version" {
  description = "Enter the nodejs version value"
  type        = string
}

variable "github_repo_url" {
  description = "Enter the github repo url for environment variable used in buildspec yml"
  type        = string
}

variable "secretsmanager_sonar_token" {
  description = "Enter the token value of SonarQube stored in secrets manager"
  type        = string
}

variable "ssm_parameter_sonar_host" {
  description = "Enter the host value of SonarQube stored in ssm parameter"
  type        = string
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
}

variable "project_root_directory" {
  description = "Enter the project root directory value stored in ssm paramter"
  type        = string
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
}

variable "sg_name" {
  description = "name of the security group"
  type        = string
}

variable "sg_description" {
  description = "vpc id for security group"
  type        = string
}

variable "s3_static_web_bucket_name" {
  description = "Enter the bucket name"
  type        = string
}

variable "aws_cloudfront_distribution_id" {
  description = "aws cloudfront distribution id"
  type        = string
}

variable "package_manager" {
  description = "Valid values for package manager are (npm, yarn)"
  type        = string

  validation {
    condition     = contains(["npm", "yarn"], var.package_manager)
    error_message = "Valid values for package manager are (npm, yarn). Please select on these as package_manager parameter."
  }
}

variable "secretsmanager_github_token_secret_name" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
}

variable "unit_test_commands" {
  description = "The commands to execute unit tests"
  type        = string
  default     = ""
}