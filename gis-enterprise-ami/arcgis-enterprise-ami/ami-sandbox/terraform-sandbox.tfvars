account_num = "874578101770" #"AWS Account Number"
aws_role    = "CloudAdmin"   #"Role to use to managee the resource ex:elevate_ops"
role        = "CloudAdmin"
user        = "CloudAdmin" #"LanID of the creator"

environment = "Dev" #Dev, Test, QA, Prod (only one)

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
  from             = 2049,
  to               = 2049,
  protocol         = "tcp",
  cidr_blocks      = ["10.89.208.0/21"] #"Account Subnets cidr range comma seperated if you have multiple."
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "Enterprise Dev Account cidr Ingress rules"
  }, {
  from             = 443,
  to               = 443,
  protocol         = "tcp",
  cidr_blocks      = ["10.89.208.0/21"] #"Account Subnets cidr range comma seperated if you have multiple."
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "Enterprise Dev Account cidr Ingress rules"
},{
  from             = 8443,
  to               = 8443,
  protocol         = "tcp",
  cidr_blocks      = ["10.89.208.0/21"] #"Account Subnets cidr range comma seperated if you have multiple."
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "Enterprise Dev Account cidr Ingress rules"
},{
  from             = 6443,
  to               = 6443,
  protocol         = "tcp",
  cidr_blocks      = ["10.89.208.0/21"] #"Account Subnets cidr range comma seperated if you have multiple."
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "Enterprise Dev Account cidr Ingress rules"
},{
  from             = 7443,
  to               = 7443,
  protocol         = "tcp",
  cidr_blocks      = ["10.89.208.0/21"] #"Account Subnets cidr range comma seperated if you have multiple."
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "Enterprise Dev Account cidr Ingress rules"
},{
  from             = 2443,
  to               = 2443,
  protocol         = "tcp",
  cidr_blocks      = ["10.89.208.0/21"] #"Account Subnets cidr range comma seperated if you have multiple."
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "Enterprise Dev Account cidr Ingress rules"
},{
  from             = 0,
  to               = 65535,
  protocol         = "tcp",
  cidr_blocks      = ["10.89.208.0/21"] #"Account Subnets cidr range comma seperated if you have multiple."
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "Enterprise Dev Account cidr Ingress rules"
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

######################################################################################
#                               EBS Volume Variables                                 #
######################################################################################

throughput = "200" #"throughput of the volume"

######################################################################################
#                               EC2 Common Variables                                 #
######################################################################################
instanceprofile   = "windows-ec2-golden-role"              #"IAM role that should be used by EC2 Machine"
securitygroupname = "sor-arcgis-enterprise-sandbox"                #"Name for Security Group"

######################################################################################
#                      Web Adaptor Machins Variables                                 #
######################################################################################
webadaptormachinecount  = "1"                                 #"Number of WebAdapter Machines"
webadaptername          = "sor-11-5-arcgis-webadaptor-sandbox" #"Name of the WebAdaptor Machine"
webadaptorprimaryvolume = "100"                               #"Primary Volume Size"
webadaptorinstancetype  = "m8i.large"                         #"Instancetpy Ex: g4dn.large"

######################################################################################
#                             ArcGIS Portal Variables                                #
######################################################################################
portalmachinename      = "sor-11-5-arcgis-portal-sandbox"    #"Name of the Portal Machine"
portalprimaryvolume    = "100"                              #"Portal Primary Volume Size"
portalinstancetype     = "m8i.2xlarge"                      #"Instancetpy Ex: g4dn.large"
portal_bucket_name     = "sor-11-5-entgis-arcgis-portal-s3-sandbox-dev" #"Bucket Name for Portal"
portal_webadaptor_name = "portal"
portalefsname          = "sor-11-5-arcgis-portal-efs-sandbox"
######################################################################################
#                         Hosted Server Machines Variables                           #
######################################################################################
hostedservermachinecount      = "1"                              #"Number of Hosted Machines"
hostedservermachinename       = "sor-11-5-arcgis-hosting-sandbox" #"Name of the Hosted Machine"
hostedserverprimaryvolume     = "100"                            #"Hosted Primary Volume Size"
hostedserverinstancetype      = "m8i.2xlarge"                    #"Instancetpy Ex: g4dn.large"
server_webadaptor_name_hosted = "hosted"                         #"Web Adaptor name for HOSTED Site"
hostedefsname                 = "sor-11-5-arcgis-hosting-efs-sandbox"
######################################################################################
#                         DataStore Machines Variables                               #
######################################################################################
datastoremachinecount  = "1"                                #"Number of Hosted Machines"
datastoremachinename   = "sor-11-5-arcgis-datastore-sandbox" #"Name of the Hosted Machine"
datastoreprimaryvolume = "100"                              #"Hosted Primary Volume Size"
datastoreinstancetype  = "r8i.xlarge"                       #"Instancetpy Ex: g4dn.large"
datastoreebsname       = "sor-11-5-arcgis-datastore-ebs-sandbox" #"DataStore EBS volume name"
stores                 = "relational"                        #"Types of data stores (relational, tilecache, spatiotemporal,graph)"

######################################################################################
#                        ENT Site ArcGIS Server Machines Variables                           #
######################################################################################
arcgisserverprimaryvolume = "100"                              #"Hosted Primary Volume Size"
arcgisserverinstancetype  = "r8i.2xlarge"                      #"Instancetpy Ex: g4dn.large"
entservermachinename       = "sor-11-5-arcgis-server-ent-sandbox" #"Name of the ENT Server Machine"
entserverefsname           = "sor-11-5-arcgis-server-efs-ent-sandbox" #"Name of the ENT Server EFS"
server_webadaptor_name_ent = "ent"                               #"Web Adaptor name for ENT Site"

######################################################################################
#                           ALB Variables                                             #
#######################################################################################

domain_name = "bcgis-sor-sandbox.nonprod.pge.com"
iam_name    = "sor-11-5-arcgis-enterprise-linux"

alb_name          = "sor-arcgis-enterprise-alb-sbox"
zone_id           = "Z1PO7XO596QKJW"
alb_bucket_name   = "ccoe-alb-accesslogs-spoke-us-west-2-874578101770-prod"
tomcat_home       = "/opt/tomcat-9.0.106"
wa_war_file       = "/opt/arcgis/webadaptor11.5/java/arcgis.war"
tf_workspace_name = "dev-entgis-sor"
arcgis_version    = "11.5"


bucket_name                = "elevate-installer"
portal_license_file_s3_key = "esri/arcgis-enterprise/11-5/license/dev/Ent-SoR-200-Viewers-100-Cretors-20-ProfessionalPlus-20-Professional-20-MobileWorker_Portal_115_548684_20260106.json"
server_license_file_s3_key = "esri/arcgis-enterprise/11-5/license/server/Elevate- ArcGIS Server STD 11.5-StreetMap Premium_1581970.prvc"
portal_ssl_cert_file_s3_key = ""
portal_ssl_cert_password = ""

################### AMI DETAILS #################
server_ami = "ami-0a639569223b2c1e4"
datastore_ami = "ami-029d017af3e936abe"
hosted_server_ami = "ami-0a639569223b2c1e4"
portal_ami = "ami-06e6587fa5862a5bf"
webadapter_ami = "ami-002c82f2e96862bc9"
tfc_role = "tfc-oidc-dev-entgis-arcgis-enterprise-sandbox-role"
targetgroup_name = "entgis-sor-sandbox-targetgroup"