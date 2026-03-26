aws_region  = "us-west-2"
account_num = "056672152820"
aws_role    = "CloudAdmin"
kms_role    = "TF_Developers"


# Tag variables

AppID              = "1001"                                           #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment        = "Dev"                                            #Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Privileged (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order = 8115205 #Order must be between 7 and 9 digits

# Variables for Glue Resources

name = "test-iac-glue-tf-1"

# Variables for Glue Job

glue_job_command = [
  {
    "script_location" = "s3://test-iac-s3-bucket/glue_script.py"
  }
]

availability_zone = "us-west-2a"

# Variables for IAM Role

role_service    = ["glue.amazonaws.com"]
iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]

# Variables for Glue Connection

glue_connection_type = "NETWORK"

# Variables for Glue Dev Endpoint

glue_dev_endpoint_extra_jars_s3_path        = "s3://test-iac-s3-bucket/read"
glue_dev_endpoint_extra_python_libs_s3_path = "s3://test-iac-s3-bucket/read"
glue_dev_endpoint_glue_version              = "0.9"
# Accepted worker_types are Standard,G.1X and G.2X.
glue_dev_endpoint_worker_type = "G.1X"
# If the worker_type is null by default it should be Standard, then we can provide number_of_nodes otherwise it will not work.
glue_dev_endpoint_number_of_nodes = null
# If the worker_type is G.1X or G.2X, then we can provide number_of_workers otherwise it should be null.
glue_dev_endpoint_number_of_workers = 5
glue_dev_endpoint_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDvHkR3SpJUyFwVHGUtYd1cGWpZlq/k4uAsQ0/hbwhD4aA+7j93YKbfUfdCxNzOiceKwnUfBjLlmn/S5iA2ez2fSC2Uuhuj/Xdnv6k/bzm4HCX/mr5dD5yByGr8JudITp3EByILSW/PS4yOHSXXxx/JWGLkm6j0e6E2H0GgnaNJEgkU4xZ4QLeKGP7a2RDlT+2oQpLqw+pwXZIQ+Msj9UW8vsAnUbpuTqPkbLLA2YdX781iDJGKtL0eH6uK5E3DpsvRX/IZAR3sVRiTgKr9WebOVcBBmaHtr9yKUlIXpxHTo+B023vTElr3Y4X3jjN1W0RCq31Dsj9WuGc5P9THCks/tF0i9v7AgaT0rcyAX5alDGJcF1+4rIpX1gH+LiA3GPG/GszF11aKBypuvCVWuwBJeiI3KWX6JbMLF0F/ZQppge/DbwD+pVeJnx7IVLLRFCbWX+AZIqicGgKZ/NsgiMnOR1HgaeSbx9y2k9ja3zEOUlv/dL/y0v1aWfenVOmdnM= abc@pge.com"
glue_dev_endpoint_public_keys       = []
glue_dev_endpoint_arguments = {
  "GLUE_PYTHON_VERSION" = "2"
}

# Variables for SSM Parameters

ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"

# Variables for Security Group

cidr_blocks = ["0.0.0.0/0"]

# Variables for Glue Trigger

glue_trigger_type = "CONDITIONAL"

glue_trigger_predicate = [{
  job_name = "test123"
  state    = "FAILED"
}]
