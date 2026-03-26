variable "source_type" {
  description = "The source type for the pipeline (GitHub or S3)"
  type        = string
  default     = "GitHub"
  validation {
    condition     = contains(["GitHub", "S3"], var.source_type)
    error_message = "Valid values for source_type are 'GitHub' or 'S3'."
  }
}

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

variable "metadata_http_endpoint" {
  description = "Whether the metadata service is available. Valid values include enabled or disabled"
  type        = string
}

# variable "build_args" {
#   description = "Provide the build environment variables required for codebuild"
#   type        = string
#   default     = ""
# }

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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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

variable "ssm_parameter_golden_ami_windows_name" {
  description = "The name given in parameter store for the Windows golden ami"
  type        = string
  default     = "/ami/windows/golden"
}

variable "ssm_parameter_artifactory_host" {
  description = "Enter the name of jfrog artifactory host stored in ssm parameter"
  type        = string
}

variable "secretsmanager_artifactory_token" {
  description = "Enter the name of jfrog artifactory token stored in secrets manager"
  type        = string
}

variable "secretsmanager_artifactory_user" {
  description = "Enter the name of jfrog artifactory user stored in secrets manager"
  type        = string
}

variable "secretsmanager_sonar_token" {
  description = "Enter the token value of SonarQube stored in secrets manager"
  type        = string
}

variable "ssm_parameter_artifactory_repo_key" {
  description = "Enter the name of JFrog npm Artifactory repo key to use in Terraform CodePipeline to pull the npm dependencies"
  type        = string
}

variable "dotnet_version" {
  description = "Enter the dotnet version value"
  type        = string
}

variable "github_repo_url" {
  description = "Enter the github repo url for environment variable used in buildspec yml"
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

variable "project_file" {
  description = "The path to the project file for the build process."
  type        = string
}

variable "project_key" {
  description = "A unique identifier of your project inside SonarQube"
  type        = string
}

variable "project_root_directory" {
  description = "Enter the project root directory value"
  type        = string
}

variable "artifact_name_dotnet" {
  description = "Enter the name of artifact"
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


variable "ec2_instance_type_windows" {
  description = "Instance type of the Windows ec2 instance (requires more memory than Linux)"
  type        = string
  default     = "t3.xlarge" # 4 vCPUs, 16 GB RAM for Windows builds
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

#Codebuild projects variables
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

variable "concurrent_build_limit_codepublish" {
  description = "Maximum number of concurrent builds for the codepublish project"
  type        = number
}

variable "compute_type_codepublish" {
  description = "Information about the compute resources the build project will use in codepublish project"
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

variable "codebuild_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

#codedeploy variables
variable "deployment_tag_key" {
  type        = string
  description = "CodeDeploy Deployment Tag Key"
}

# variable "deployment_tag_value" {
#   type        = string
#   description = "CodeDeploy Deployment Tag Value"
# }

variable "deployment_type" {
  type        = string
  description = "CodeDeploy Deployment Type"
  default     = "IN_PLACE"
}

variable "codedeploy_role_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the aws_accounts variable is not provided."
  type        = list(string)
}

variable "codedeploy_app_name" {
  description = "The name of the application."
  type        = string
}

variable "deployment_option" {
  type        = string
  description = "CodeDeploy Deployment Option Indicates whether to route deployment traffic behind a load balancer,Possible values: WITH_TRAFFIC_CONTROL, WITHOUT_TRAFFIC_CONTROL."
}

variable "unit_test_commands" {
  description = "Enter the unit test commands for python webapp"
  type        = string
}

variable "secretsmanager_github_token_secret_name" {
  description = "secret manager path of the github OAUTH or PAT"
  type        = string
}

# Windows build support variables
variable "enable_windows_build" {
  description = "Enable Windows build environment for .NET projects"
  type        = bool
  default     = true
}

variable "windows_environment_type" {
  description = "Type of Windows build environment container for Windows builds"
  type        = string
  default     = "WINDOWS_SERVER_2019_CONTAINER"
  validation {
    condition = contains([
      "WINDOWS_SERVER_2019_CONTAINER",
      "WINDOWS_SERVER_2022_CONTAINER"
    ], var.windows_environment_type)
    error_message = "The windows_environment_type must be either WINDOWS_SERVER_2019_CONTAINER or WINDOWS_SERVER_2022_CONTAINER."
  }
}

variable "environment_image_codebuild_windows" {
  description = "Docker image to use for Windows codebuild project. Use Windows Server 2019 base image for .NET builds."
  type        = string
  default     = "aws/codebuild/windows-base:2019-3.0"
}

variable "environment_image_codescan_windows" {
  description = "Docker image to use for Windows codescan project. Use Windows Server 2019 base image for .NET builds."
  type        = string
  default     = "aws/codebuild/windows-base:2019-3.0"
}

variable "environment_image_codepublish_windows" {
  description = "Docker image to use for Windows codepublish project. Use Windows Server 2019 base image for .NET builds."
  type        = string
  default     = "aws/codebuild/windows-base:2019-3.0"
}

variable "environment_image_codedownload_windows" {
  description = "Docker image to use for Windows codedownload project. Use Windows Server 2019 base image for .NET builds."
  type        = string
  default     = "aws/codebuild/windows-base:2019-3.0"
}