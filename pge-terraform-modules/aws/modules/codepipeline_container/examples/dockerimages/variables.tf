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

variable "kms_key_arn" {
  description = "Enter the KMS key ARN for encryption - CodeBuild"
  type        = string
  default     = null
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

variable "secretsmanager_github_token_secret_name" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the token value of jfrog artifactory stored in secrets manager"
  type        = string
}

variable "ssm_parameter_artifactory_host" {
  description = "Enter the host value of jfrog stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_artifactory_docker_registry" {
  description = "Enter the name value of jfrog artifactory stored in ssm parameter"
  type        = string
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
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

#vairables for codebuild security group

variable "environment_image_codebuild" {
  description = "Docker image to use for this codebuild project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codebuild" {
  description = "Type of build environment to use for codebuild project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}

variable "source_location_codebuild" {
  description = " Location of the source code from git or s3 for codebuild."
  type        = string
}

variable "concurrent_build_limit_codebuild" {
  description = "Maximum number of concurrent builds for the codebuild project"
  type        = number
}

variable "compute_type_codebuild" {
  description = "Information about the compute resources the build project will use in codebuild project"
  type        = string
}

variable "artifact_bucket_owner_access" {
  description = "Enter the artifact bucket owner access"
  type        = string
}

variable "artifact_path" {
  description = "Enter the path to store artifact - S3"
  type        = string
}

variable "codebuild_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

# wiz
variable "secretsmanager_wiz_client_id" {
  description = "Enter the name of wiz client id stored in secrets manager"
  type        = string
  default     = "shared-wiz-access:WIZ_CLIENT_ID"
}

variable "secretsmanager_wiz_client_secret" {
  description = "Enter the token of wiz client secret stored in secrets manager"
  type        = string
  default     = "shared-wiz-access:WIZ_CLIENT_SECRET"
}

variable "DockerImage_name" {
  description = "Enter the docker image name for docker build"
  type        = string
}

###################### SNS Variables #############################

variable "endpoint_email" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
}

################### SNS Variables END ##########################
variable "publish_docker_registry" {
  description = "Docker registry to publish the image. BOTH will publish the image to both ECR and JFROG. JFROG image will be considered default for the deployment"
  type        = string
  default     = "JFROG"
  validation {
    condition     = contains(["ECR", "JFROG", "BOTH"], var.publish_docker_registry)
    error_message = "Valid values for docker registry are ECR, JFROG and BOTH."
  }
}

#variables for aws_iam_role
variable "codepipeline_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
  default     = ["codepipeline.amazonaws.com"]
}

variable "app_owners" {
  description = "Enter app owners for docker image tag"
  type        = string
}

variable "s3_bucket" {
  description = "The name of the S3 bucket to be used"
  type        = string
  default     = ""
}