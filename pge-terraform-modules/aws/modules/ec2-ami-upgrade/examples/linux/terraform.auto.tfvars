aws_region = "us-west-2"
role_name = "lambda-ssm-role"
trusted_aws_principals = ["arn:aws:iam::750713712981:root"]
description = "This role is used for managing EC2 AMI upgrades"
path = "/"
account_id = "750713712981"
excluded_asgs = ["atcv-template-3", "acv-asg-2", "eks-admin_nodegroup-8eca1eb3-7ee0-145e-22b9-b3d4f52bc314", "eks-single-az-46ca1eb3-7edb-77fc-17d0-1933b0d4cdd3", "az-failure-demo-targets-v4-FISAutoScalingGroup-O0vpQ2b59Vxt", "auto-patch-asg-lt-ccoe-test", "cpsa-test-asg"]
excluded_instances = ["i-010187d3e6707e8de", "i-0a5976f68179dc3d9", "i-09953d1342ecabce3", "i-0fdccf4a7084be341", "i-0f5ad4c6cca9c92a9", "i-028448b7e3ae02851", "i-05546e3aaf6f0d31c", "i-05ef92f36b650f29c", "i-0ab326e08791ea2cb", "i-07d725e559f9ab17e", "i-054e46329bf901ea8", "i-00e882747d93d0166", "i-0a6e1d4f744cb4260"]
asg_configurations = {
    "atcv-test-asg" = { min = 1, max = 2, desired = 2}
}

AppID              = "2102"                                           # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"                                            # Dev, Test, QA, Prod (only one)
DataClassification = "Internal"                                       # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["atcv@pge.com"] # Who to notify for system failure or maintenance. Should be a group or list of email addresses.
Owner              = ["atcv", "s3kv", "a2vb"]                         # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                                         # Identify assets with compliance requirements SOX, HIPAA, CCPA or None

vpc_config_security_group_ids = ["sg-0f81cdd051fb1a32d"]
vpc_config_subnet_ids = ["subnet-0ce9bc280b58f1c60"]
kms_key_arn = "arn:aws:kms:us-west-2:750713712981:key/03cbf668-2183-4140-a87c-5423ecd1da45"
policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
aws_service = ["lambda.amazonaws.com"]