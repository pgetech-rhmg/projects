##### General configuration
account_num     = "514712703977"
account_num_r53 = "514712703977"
aws_region      = "us-west-2"
aws_role        = "CloudAdmin"
kms_role        = "CloudAdmin"
AppID           = "1001"
Environment     = "Dev" # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"      # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["sukx@pge.com", "oxdi@pge.com", "e6bo@pge.com"]
Owner              = ["sukx", "oxdi", "e6bo"] # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205 # Order must be between 7 and 9 digits

##### General cluster configuration
cluster_name       = "eks-auto-test" # Theres 2 other places to update cluster name, do a find in this file for "#CLUSTER NAME"
hosted_zone        = "nonprod.pge.com"
domain_env         = "nonprod"
k8s-version        = "1.34"
argocd_git_auth    = "shared-argo-github-pat"         # Name of the GitHub PAT for ArgoCD to authenticate to pgetech/ccoe-managed-eks-addons
codebuild_git_auth = "shared-codebuild-github-pat"    # Name of the GitHub PAT in Secrets Manager for codebuild to auth to pgetech/ccoe-managed-eks-addons
custom_repo_url    = "https://github.com/pgetech/..." # Your GitHub repository URL for ArgoCD applications
custom_repo_branch = ""                               # Your GitHub repo branch for ArgoCD applications

# Access Entries are simply what IAM principals have access to the cluster, and what level of access they have.
access_entries = {
  clusteradmins  = ["SecurityAdmin", "CloudAdmin"]
  clustereditors = []
  clusterviewers = [
    {
      role       = "SuperAdmin"
      namespaces = []
    }
  ]
}

##### CCOE managed addons configuration - creates AWS resources that addons rely on ########
# If you are not using the addons, you can set these to false
# Once the addon resources are created, then you can commit your ArgoCD applications to your repo
create_efs_csi_resources           = false
create_custom_role                 = false
create_cloudwatch_agent            = false
create_aws_for_fluentbit_resources = false
create_loki_resources              = false
create_mimir_resources             = false
create_tempo_resources             = false

#
#
########################################################################################################
##### Advanced Configuration: You likely don't need to change these unless you know what you are doing #
########################################################################################################
#
#
parameter_vpc_id_name     = "/vpc/id"
parameter_subnet_id1_name = "/vpc/privatesubnet1/id"
parameter_subnet_id2_name = "/vpc/privatesubnet2/id"
parameter_subnet_id3_name = "/vpc/privatesubnet3/id"

sns-topic = "arn:aws:sns:us-west-2:750713712981:eks-alarms-topic"

external_secrets_kms_key_arns = []

#custom role
custom_identity = "custom-role"
custom_identity_associations = {
  ex-one = {
    cluster_name    = "e6bo-auto-test" #CLUSTER NAME
    namespace       = "custom"
    service_account = "custom"
  }
}
