variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "kms_name" {
  type        = string
  description = "KMS key name for customer managed key encryption"
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

variable "ssm_parameter_artifactory_repo_name" {
  description = "Enter the artifact repo name of jfrog stored in ssm parameter"
  type        = string
}

variable "secretsmanager_github_token_secret_name" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
}

variable "ssm_parameter_artifactory_host" {
  description = "Enter the host value of jfrog stored in ssm parameter"
  type        = string
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the token value of jfrog artifactory stored in secrets manager"
  type        = string
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
  type        = string
}

variable "secretsmanager_sonar_token" {
  description = "Enter the token of SonarQube stored in secrets manager"
  type        = string
}

variable "ssm_parameter_sonar_host" {
  description = "Enter the host value of SonarQube stored in ssm parameter"
  type        = string
}

variable "project_name" {
  description = "The display name visible in SonarQube dashboard. Example: My Project"
  type        = string
}

variable "ssm_parameter_golden_ami_name" {
  description = "The name given in parameter store for the golden ami"
  type        = string
}

variable "project_key" {
  description = "A unique identifier of your project inside SonarQube"
  type        = string
}

variable "project_root_directory" {
  description = "Enter the project root directory - variable in buildspec yml"
  type        = string
}

variable "dependency_files_location" {
  description = "Enter the dependency file location - environment variable used in buildspec yml"
  type        = string
}

variable "unit_test_commands" {
  description = "Enter the unit test commands for python webapp"
  type        = string
}

variable "github_repo_url" {
  description = "Enter the github repo url for environment variable used in buildspec yml"
  type        = string
}

#######################
variable "bucket_name" {
  description = "Bucket name for codepipeline"
  type        = string
}

#variables for aws_iam_role
variable "codepipeline_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
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

variable "sg_name_codebuild" {
  description = "name of the security group"
  type        = string
}

variable "sg_description_codebuild" {
  description = "vpc id for security group"
  type        = string
}

#EC2 & SG
variable "sg_name_ec2" {
  description = "Name of the security group for EC2 configuration"
  type        = string
}

variable "sg_description_ec2" {
  description = "Security group for example usage with EFS"
  type        = string
}

variable "cidr_ingress_rules_ec2" {
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

variable "cidr_egress_rules_ec2" {
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

variable "ec2_name" {
  type        = string
  description = "The name for ec2 instance"
}


variable "ec2_instance_type" {
  description = "Instance type of the ec2 instance"
  type        = string
}

variable "ec2_az" {
  description = "Availability Zone of the EC2"
  type        = string
}

variable "root_block_device_volume_type" {
  description = "Volume type of the root block device"
  type        = string
}

variable "root_block_device_throughput" {
  description = "Throughput of the root block device"
  type        = number
}

variable "root_block_device_volume_size" {
  description = "Volume size of the root block device"
  type        = number
}

variable "metadata_http_endpoint" {
  description = "Whether the metadata service is available. Valid values include enabled or disabled"
  type        = string
}

#Codebuild projects variables
variable "environment_image_codebuild" {
  description = "Docker image to use for codebuild project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codebuild" {
  description = "Type of build environment to use for codebuild project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}
variable "custom_codebuild_policy_file" {
  description = "add custom codebuild policy file for codebuild project, if needed"
  type        = string
  default     = null
}

variable "custom_codescan_policy_file" {
  description = "add custom codescan policy file for codebuild project, if needed"
  type        = string
  default     = null
}

variable "custom_codepublish_policy_file" {
  description = "add custom codepublish policy file for codebuild project, if needed"
  type        = string
  default     = null
}


variable "source_location_codebuild" {
  description = " Location of the source code from git or s3 to build codescan project."
  type        = string
}

variable "concurrent_build_limit_codebuild" {
  description = "Maximum number of concurrent builds for the project in codebuild project"
  type        = number
}

variable "compute_type_codebuild" {
  description = "Information about the compute resources the build project will use in codebuild project"
  type        = string
}

variable "environment_image_codepublish" {
  description = "Docker image to use for this codepublish project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codepublish" {
  description = "Type of build environment to use for codepublish project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}

variable "concurrent_build_limit_codepublish" {
  description = "Maximum number of concurrent builds for the codepublish project"
  type        = number
}

variable "compute_type_codepublish" {
  description = "Information about the compute resources the build project will use in codepublish project"
  type        = string
}

variable "environment_image_codescan" {
  description = "Docker image to use for this codescan project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codescan" {
  description = "Type of build environment to use for codescan related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}

variable "concurrent_build_limit_codescan" {
  description = "Maximum number of concurrent builds for the codescan project"
  type        = number
}

variable "compute_type_codescan" {
  description = "Information about the compute resources the build project will use in codescan project"
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

variable "environment_image_codetest" {
  description = "Docker image to use for codetest project. Valid values include Docker images provided by codebuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g., hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g., 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
  type        = string
}

variable "environment_type_codetest" {
  description = "Type of build environment to use for codebuild project related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SER_2019_CONTAINER, ARM_CONTAINER. "
  type        = string
}

variable "concurrent_build_limit_codetest" {
  description = "Maximum number of concurrent builds for the project in codebuild project"
  type        = number
}

variable "compute_type_codetest" {
  description = "Information about the compute resources the build project will use in codebuild project"
  type        = string
}

variable "python_runtime" {
  description = "Enter the python version to compile application code - variable in buildspec yml"
  type        = string
  validation {
    condition     = contains(["3.7", "3.8", "3.9", "3.10"], var.python_runtime)
    error_message = "Python_runtime must be one of '3.7', '3.8', '3.9','3.10'."
  }
}

#variables for aws_iam_role
variable "codetest_role_name" {
  description = "Name of the iam role for codepublish project"
  type        = string
}

variable "codebuild_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "codedeploy_role_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the aws_accounts variable is not provided."
  type        = list(string)
}

#codedeploy variables
variable "deployment_tag_key" {
  type        = string
  description = "CodeDeploy Deployment Tag Key"
}

variable "deployment_tag_value" {
  type        = string
  description = "CodeDeploy Deployment Tag Value"
}

variable "deployment_type" {
  type        = string
  description = "CodeDeploy Deployment Type"
  default     = "IN_PLACE"
}
#variables for the module codedeploy_app_ec2
variable "codedeploy_app_name" {
  description = "The name of the application."
  type        = string
}
