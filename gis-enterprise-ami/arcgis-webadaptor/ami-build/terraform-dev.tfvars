# tags
AppID                            = "3696" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment                      = "Dev"  #Dev, Test, QA, Prod (only one)
DataClassification               = "Internal" #Public, Internal, Confidential, Restricted, Confidential-BCSI, Restricted-BCSI (only one)
CRIS                             = "Medium"   #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify                           = ["grn0@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner                            = ["grn0","KDMd","G1CR"] #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance                       = ["None"]
name                             = "imagebuilder-rhel-arcgis-webadaptor" #"Name of the project which will be used as a prefix for every resource."
Order                            = "8221088" #"A numeric value that defines the order of importance for this resource relative to other resources you may have."

# AWS Configuration
aws_region                       = "us-west-2"
account_num                      = "587401437202"
aws_role                         = "CloudAdmin"

# Build Configuration
cidr_ingress_rules = [{
  from             = 443,
  to               = 443,
  protocol         = "tcp",
  cidr_blocks      = ["10.0.0.0/8"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "ec2 ingress rule to access it from pge network - 1"
  }, {
  from             = 443,
  to               = 443,
  protocol         = "tcp",
  cidr_blocks      = ["172.16.0.0/12"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "ec2 ingress rule to access it from pge network - 2"
  }, {
  from             = 443,
  to               = 443,
  protocol         = "tcp",
  cidr_blocks      = ["192.168.0.0/16"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "ec2 ingress rule to access it from pge network - 3"
}, {
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.88.102.0/24", "10.88.101.0/24", "10.88.100.0/24", "10.88.103.128/25", "10.88.103.0/25"]    #"Account Subnets cidr range comma seperated if you have multiple."
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "GOGIS Dev Account cidr Ingress rules"
}]
cidr_egress_rules = [{
  from             = 0,
  to               = 65535,
  protocol         = "tcp",
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "ec2 egress rules"
}]
build_version                   = "1.0.17"
recipe_version                  = "1.0.17"
ami_name                         = "rhel-arcgis-webadaptor-ami"
# Image Builder S3 Bucket Configuration 
log_policy                       = "s3_log_policy.json"
bucket_name                      = "imagebuilder-rhel-arcgis-webadaptor-logs"
# Software Sources
deployment_bucket               = "elevate-installer"
workflow_installer_key_name     = "esri/arcgis-enterprise/11-5/ArcGIS_Workflow_Manager_Server_115_195486.tar.gz"
webadaptor_installer_key_name   = "esri/arcgis-enterprise/11-5/ArcGIS_Web_Adaptor_Java_Linux_115_195462.tar.gz"
java_openjdk_17_key_name        = "tomcat/OpenJDK17U-jdk_x64_linux_hotspot_17.0.13_11.tar.gz"
tomcat_key_name                  = "tomcat/apache-tomcat-9.0.106.tar.gz"
