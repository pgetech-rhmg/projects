# Account numbers
account_num     = "750713712981"
account_num_r53 = "514712703977"

# Roles to assume
aws_role     = "CloudAdmin"
kms_role     = "CloudAdmin"
aws_r53_role = "CloudAdmin"

# Secrets Manager variables for Codepipeline
secretsmanager_github_token      = "github_token_r5vd:pat"
secretsmanager_artifactory_user  = "jfrog_credentials:jfrog_user"
secretsmanager_artifactory_token = "jfrog_credentials:jfrog_token"
secretsmanager_sonar_token       = "sonarqube_credentials:sonar_token"

# SSM Parameter Store variables for Codepipeline

# Misc
aws_region            = "us-west-2"
cloudfront_priceclass = "PriceClass_200" # The price class of the CloudFront Distribution. Valid types are PriceClass_All, PriceClass_100, PriceClass_200
build_args1           = ""               # Optional

project_key  = "s3-static-web-react-npm"
project_name = "s3-static-web-react-npm"

# cloudfront OAC
cloudfront_oac_name = "s3web-html-oac"

# Additional KMS values
kms_name        = "pge_s3web_kms_01"
kms_description = "ccoe-pge-s3web-kms"

# The 7 required tags for all assets
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BCSI, please follow the steps
# detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Public" # Public, Internal, Confidential, Restricted, Privileged (only one)
AppID              = "1001"   # Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####
Environment        = "Dev"    # Dev, Test, QA, Prod (only one)
CRIS               = "Low"    # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
Owner              = ["abc1", "def2", "ghi3"] # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]                 # Identify assets with compliance requirements SOX, HIPAA, CCPA or None
Order              = 8115205                  #Order tag is required and must be a number between 7 and 9 digits

# Codepipeline variables for html
#################################
github_repo_url_html    = "https://github.com/pgetech/s3web_html.git"
github_branch_html      = "main"
bucket_name_html        = "rb1c-s3web-html"
custom_domain_name_html = "rb1c-s3web-html.nonprod.pge.com"
s3web_type_html         = "html"
project_name_html       = "s3web-html"
project_key_html        = "s3web-html"

# NOTE: Usage instructions for object lock configuration.
# Enabling object lock configuration.
# If object lock configuration is enabled, s3 Bucket versioning will automatically be "Enabled".
# Ref: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock-overview.html#object-lock-bucket-config

# object_lock_configuration = {
#   mode  = "GOVERNANCE" #Valid values are GOVERNANCE and COMPLIANCE.
#   days  = 1
#   years = null
# }

# Disabling object lock configuration.
# To create s3 bucket with no object lock configuration, use below key value pair. comment or uncomment based on your requirement.
object_lock_configuration = null

# Optional: Use existing CloudFront distribution instead of creating new one
# Uncomment the line below and provide the ARN of your existing CloudFront distribution
# existing_cloudfront_distribution_arn = "arn:aws:cloudfront::123456789012:distribution/ABCD1234EFGH"

# Optional: Control Route53 record creation
# Set to false when using F5 or other external routing mechanisms to avoid conflicts
# create_route53_records = false
