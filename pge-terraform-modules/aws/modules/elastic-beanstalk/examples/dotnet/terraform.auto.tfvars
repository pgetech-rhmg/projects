# General
account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
kms_role    = "CloudAdmin"

# Tags
AppID              = "1001"                           #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]         #"List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]                         #Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                                          #Order must be between 7 and 9 digits
optional_tags = {
  managed_by = "Terraform"
}

# Common name prefix to use
name = "tf-example-dotnet"

# parameter store names
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
ssm_parameter_subnet_id2 = "/vpc/2/privatesubnet2/id"
ssm_parameter_subnet_id3 = "/vpc/2/privatesubnet3/id"
# ssm_parameter_golden_ami_id = "/ami/linux/golden"

# Elastic Beanstalk Environment parameters
environment_solution_stack_name = "64bit Amazon Linux 2023 v3.0.0 running .NET 6"

# application_version parameters
application_version_force_delete = "true"
application_version_source_zip   = "dotnet.zip"
application_version              = "v1.0.0"

#configuration_template
solution_stack_name = "64bit Amazon Linux 2023 v3.0.0 running .NET 6"

#iam policy
aws_service = ["ec2.amazonaws.com"]
policy_arns = ["arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker", "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"]

#s3 alb logs
template_file_name = "s3_alb_logs_policy.json"

#Acm
acm_domain_name       = "nonprod.pge.com"
organization          = "ACME Examples, Inc"
private_key_algorithm = "RSA"
allowed_uses = [
  "key_encipherment",
  "digital_signature",
  "server_auth",
]

validity_period_hours = 12
