# wiz

variable "secretsmanager_wiz_client_id" {
  description = "Enter the name of wiz client id stored in secrets manager"
  type        = string
}

variable "secretsmanager_wiz_client_secret" {
  description = "Enter the token of wiz client secret stored in secrets manager"
  type        = string
}


variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "codepipeline_name" {
  description = "The name of the pipeline."
  type        = string
  default     = ""
}

variable "github_org" {
  description = "Github organization name of the repository, pgetech, DigitalCatalyst, etc"
  type        = string
}

variable "repo_name" {
  description = "Github repository name of the application to be built"
  type        = string
}

variable "branch" {
  description = "Branch of the GitHub repository, e.g 'master"
  type        = string
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

variable "environment_image_codebuild" {
  description = "Docker image to use for codebuild project"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "environment_type_codebuild" {
  description = "Type of build environment to use for codebuild project related builds"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "environment_image_codescan" {
  description = "Docker image to use for this codescan project"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "environment_type_codescan" {
  description = "Type of build environment to use for codescan related builds"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "environment_image_codepublish" {
  description = "Docker image to use for this codepublish project"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "environment_type_codepublish" {
  description = "Type of build environment to use for codepublish project related builds"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "codebuild_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
  default     = ["codebuild.amazonaws.com"]
}

variable "source_location_codebuild" {
  description = "Location of the source code from git or s3 to build project"
  type        = string
  default     = ""
}

variable "concurrent_build_limit_codebuild" {
  description = "Maximum number of concurrent builds for the project in codebuild project"
  type        = number
  default     = 1
}

variable "concurrent_build_limit_codescan" {
  description = "Maximum number of concurrent builds for the codescan project"
  type        = number
  default     = 1
}

variable "concurrent_build_limit_codepublish" {
  description = "Maximum number of concurrent builds for the codepublish project"
  type        = number
  default     = 1
}

variable "compute_type_codebuild" {
  description = "Information about the compute resources the build project will use in codebuild project"
  type        = string
  default     = "BUILD_GENERAL1_MEDIUM"
}

variable "compute_type_codescan" {
  description = "Information about the compute resources the build project will use in codescan project"
  type        = string
  default     = "BUILD_GENERAL1_MEDIUM"
}

variable "compute_type_codepublish" {
  description = "Information about the compute resources the build project will use in codepublish project"
  type        = string
  default     = "BUILD_GENERAL1_MEDIUM"
}

variable "artifact_path" {
  description = "Enter the path to store artifact - S3"
  type        = string
  default     = ""
}

variable "artifact_bucket_owner_access" {
  description = "Enter the artifact bucket owner access"
  type        = string
  default     = "FULL"
}

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
  default = [
    {
      from             = 0
      to               = 65535
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "All outbound traffic"
    },
    {
      from             = 0
      to               = 65535
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "All outbound traffic"
    }
  ]
}

variable "sg_name" {
  description = "name of the security group"
  type        = string
  default     = "codebuild_sg"
}

variable "sg_description" {
  description = "vpc id for security group"
  type        = string
  default     = "Security group for CodeBuild"
}

variable "sg_name_lambda" {
  description = "name of the security group for lambda"
  type        = string
  default     = "lambda_sg"
}

variable "sg_description_lambda" {
  description = "security group description for lambda"
  type        = string
  default     = "Security group for Lambda function"
}

variable "bucket_name" {
  description = "Bucket name for codepipeline"
  type        = string
}

variable "codepipeline_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
  default     = ["codepipeline.amazonaws.com"]
}

variable "image_uri" {
  description = "ECR image URI placeholder for lambda_image module (e.g. 750713712981.dkr.ecr.us-west-2.amazonaws.com/repo:tag)"
  type        = string
  default     = ""
}

# Java-specific Docker variables
variable "project_key" {
  description = "A unique identifier of your project inside SonarQube"
  type        = string
}

variable "project_name" {
  description = "The display name visible in SonarQube dashboard. Example: My Project"
  type        = string
}

variable "project_root_directory" {
  description = "Enter the project root directory - environment variable used in buildspec yml"
  type        = string
}

variable "dependency_files_location" {
  description = "Enter the dependency file location - environment variable used in buildspec yml"
  type        = string
  default     = "pom.xml"
}

variable "artifactory_repo_name" {
  description = "Enter the artifact repo name of jfrog - environment variable used in buildspec yml"
  type        = string
  default     = "java-local"
}

variable "github_repo_url" {
  description = "Enter the github repo url - environment variable used in buildspec yml"
  type        = string
  default     = ""
}

variable "unit_test_commands" {
  description = "Default is empty as sonar scan command will be used to run unit tests as well"
  type        = string
  default     = ""
}

#secrets manager variables
variable "secretsmanager_github_token_secret_name" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
  type        = string
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the token value of jfrog artifactory stored in secrets manager"
  type        = string
}

variable "secretsmanager_sonar_token" {
  description = "Enter the token of SonarQube stored in secrets manager"
  type        = string
}

#ssm parameter variables
variable "ssm_parameter_artifactory_host" {
  description = "enter the ssm_parameter path for artifactory_host"
  type        = string
}

variable "ssm_parameter_artifactory_docker_registry" {
  description = "enter the ssm_parameter path for artifactory_docker_registry"
  type        = string
  default     = null
}

variable "ssm_parameter_sonar_host" {
  description = "enter the ssm_parameter path for sonar host"
  type        = string
}

variable "sonar_scanner_cli_version" {
  description = "Enter the SonarScanner CLI version for Java analysis"
  type        = string
  default     = "4.6.2.2472"
}

variable "lambda_function_name" {
  description = "Enter the name of the Lambda Function"
  type        = string
}

variable "lambda_alias_name" {
  description = "Enter the name of the Lambda alias"
  type        = string
}

variable "lambda_update" {
  description = "Input from the user to update lambda function with container image or not"
  type        = bool
  default     = true
}

variable "include_lib_files" {
  description = "Set it to false if lib files need not to be added"
  type        = bool
  default     = true
}

variable "description" {
  description = "Description of the lambda function"
  type        = string
  default     = "Java Lambda function using Docker containers"
}

# Docker-specific variables
variable "docker_image_name" {
  description = "Name of the Docker image to be built for the Java Lambda"
  type        = string
}

variable "publish_docker_registry" {
  description = "Where to publish the Docker image (ECR, JFROG, or BOTH)"
  type        = string
  default     = "ECR"
  validation {
    condition     = contains(["ECR", "JFROG", "BOTH"], var.publish_docker_registry)
    error_message = "Valid values are 'ECR', 'JFROG', or 'BOTH'."
  }
}

variable "app_owners" {
  description = "Application owners for Docker image metadata"
  type        = string
  default     = "PGE-DevOps"
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "java_runtime" {
  description = "Java runtime version for Docker builds"
  type        = string
}

variable "runtime" {
  description = " Identifier of the function's runtime"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
}

#variables for security_group
variable "lambda_cidr_ingress_rules" {
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

variable "lambda_cidr_egress_rules" {
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

variable "lambda_sg_name" {
  description = "name of the security group"
  type        = string
}

variable "lambda_sg_description" {
  description = "vpc id for security group"
  type        = string
}

#variables for aws_lambda_iam_role
variable "lambda_iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "lambda_iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "lambda_iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy to Lambda (e.g., CodeBuild output tag or timestamp)."
  type        = string
  default     = ""
}

variable "source_location_wizscan" {
  description = "Source location for the wizscan stage"
  type        = string
}

variable "aws_account_number" {
  description = "Enter the provisoninged account number "
  type        = number
}

variable "container_name" {
  description = "Enter the application container name"
  type        = string
}