
variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "route53_aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "role" {
  type = string
}

variable "user" {
  type = string
}

variable "appid" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "dataclassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "cris" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "optional_tags" {
  description = "Optional tags for resource"
  type        = map(string)
  default     = {}
}

variable "metadata_http_endpoint" {
  description = "Whether the metadata service is available. Valid values include enabled or disabled"
  type        = string
}

variable "order" {
  type = number
}

variable "availabilityzonea" {
  type = string
}

variable "availabilityzoneb" {
  type = string
}

variable "availabilityzonec" {
  type = string
}

############# alb_certificate #################
variable "account_num_r53" {
  type        = string
  description = "Target route53 AWS account number, mandatory"
  default     = "514712703977"
}

variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume to work with r53 account_number"
  default     = "CloudAdmin"
}

######################################################################################
#                               EBS Volume Variables                                 #
######################################################################################

variable "throughput" {
  type    = string
  default = "200"
}

######################################################################################
#                               Security Group Variables                             #
######################################################################################

variable "securitygroupname" {
  type = string
}

variable "cidr_ingress_rules" {
  description = "Ingress rule for the CIDR network range"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = []
}

variable "cidr_egress_rules" {
  description = "Egress rule for the CIDR network range"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = []
}

######################################################################################
#                           Web Adaptor EC2 Variables                                #
######################################################################################

variable "instanceprofile" {
  type    = string
  default = "windows-ec2-golden-role"
}

variable "webadaptormachinecount" {
  type = string
}

variable "webadaptername" {
  type    = string
  default = "sor-11-5-arcgis-webadaptor-sandbox"
}

variable "webadaptorprimaryvolume" {
  type    = string
  default = "100"
}

variable "webadaptorinstancetype" {
  type        = string
  description = "EC2 Instance type"
  default     = "m8i.large"
}

######################################################################################
#                           ArcGIS Portal EC2 Variables                              #
######################################################################################

variable "portalprimaryvolume" {
  type    = string
  default = "100"
}

variable "portalmachinename" {
  type    = string
  default = "sor-11-5-arcgis-portal-sandbox"
}

variable "portalinstancetype" {
  type        = string
  description = "EC2 Instance type"
  default     = "m8i.2xlarge"
}

variable "portal_bucket_name" {
  type    = string
  default = "sor-11-5-arcgis-portal-s3-sandbox"
}

variable "versioning" {
  type        = string
  default     = "Disabled"
  description = "Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from Terraform state if the associated S3 bucket is unversioned."
}

######################################################################################
#                           Hosted Server EC2 Variables                              #
######################################################################################

variable "hostedserverprimaryvolume" {
  type    = string
  default = "100"
}

variable "hostedservermachinecount" {
  type = string
}

variable "hostedservermachinename" {
  type    = string
  default = "sor-11-5-arcgis-hosting-sandbox"
}

variable "hostedserverinstancetype" {
  type        = string
  description = "EC2 Instance type"
  default     = "m8i.2xlarge"
}

######################################################################################
#                               DataStore EC2 Variables                              #
######################################################################################

variable "datastoreprimaryvolume" {
  type    = string
  default = "100"
}

variable "datastoremachinecount" {
  type = string
}

variable "datastoremachinename" {
  type    = string
  default = "sor-11-5-arcgis-datastore-sandbox"
}

variable "datastoreinstancetype" {
  type        = string
  description = "EC2 Instance type"
  default     = "r8i.2xlarge"
}
variable "stores" {
  type    = string
  description = "Types of data stores (relational, tilecache, spatiotemporal,graph)"
  default = "relational"
}

######################################################################################
#                               ArcGIS Server EC2 Variables                          #
######################################################################################

variable "arcgisserverprimaryvolume" {
  type    = string
  default = "100"
}

variable "ArcGISServerMachineCount" {
  type    = string
  default = "1"
}

variable "arcgisserverinstancetype" {
  type        = string
  description = "EC2 Instance type"
  default     = "r8i.2xlarge"
}

variable "server_webadaptor_name_hosted" {
  type = string
}

variable "server_webadaptor_name_ent" {
  type = string
}

variable "entservermachinename" {
  type = string
}

############### ALB Variables ##################

variable "domain_name" {
  type = string
}

variable "iam_name" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "alb_bucket_name" {
  type = string
}

variable "tf_workspace_name" {
  type = string
}

variable "portal_webadaptor_name" {
  type = string
}

variable "bucket_name" {
  type    = string
  default = "elevate-installer"
}

variable "portal_license_file_s3_key" {
  type = string
}

variable "server_license_file_s3_key" {
  type = string
}

variable "portal_ssl_cert_file_s3_key" {
  type = string
}

variable "portal_ssl_cert_password" {
  type = string
}

######################################################################################
#                               Secrets Manager Variables                          #
######################################################################################
variable "portal_secretsmanager_name" {
  description = "portal siteadmin secret"
  type        = string
  default     = "sandbox/portal-siteadmin"
}

variable "portal_secretsmanager_description" {
  type    = string
  default = "Portal Siteadmin secrets manager"
}

variable "server_secretsmanager_name" {
  description = "server siteadmin secret"
  type        = string
  default     = "sandbox/server-siteadmin"
}

variable "server_secretsmanager_description" {
  type    = string
  default = "Server siteadmin secrets manager"
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 0
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
  default     = true
}

variable "server_admin_user" {
  type    = string
  default = "siteadmin"
}

variable "portal_admin_user" {
  type    = string
  default = "portaladmin"
}

variable "tomcat_home" {
  type = string
}

variable "wa_war_file" {
  type = string
}

variable "arcgis_version" {
  type = string
}

variable "hostedefsname" {
  type = string
}

variable "portalefsname" {
  type = string
}

variable "entserverefsname" {
  type = string
}

variable "datastoreebsname" {
  type = string
  default = "sor-11-5-arcgis-datastore-ebs-sandbox"
}

################### AMI Variables #################
variable "server_ami" {
  type = string
}

variable "datastore_ami" {
  type = string
}

variable "hosted_server_ami" {
  type = string
}

variable "portal_ami" {
  type = string
}

variable "webadapter_ami" {
  type = string
}

variable "tfc_role" {
  type = string
}

variable "targetgroup_name" {
  type = string
}