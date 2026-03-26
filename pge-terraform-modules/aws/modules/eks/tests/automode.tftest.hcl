run "automode" {
  command = apply

  module {
    source = "./examples/automode"
  }
}

variables {
  account_num        = "514712703977"
  account_num_r53    = "514712703977"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["sukx@pge.com", "oxdi@pge.com", "e6bo@pge.com"]
  Owner              = ["sukx", "oxdi", "e6bo"]
  Compliance         = ["None"]
  Order              = 8115205
  cluster_name       = "e6bo-auto-test"
  hosted_zone        = "nonprod.pge.com"
  domain_env         = "nonprod"
  k8s-version        = "1.34"
  argocd_git_auth    = "shared-argo-github-pat"
  codebuild_git_auth = "shared-codebuild-github-pat"
  custom_repo_url    = "https://github.com/pgetech/e6bo-tf-testing"
  custom_repo_branch = "dev"
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
  create_efs_csi_resources           = false
  create_custom_role                 = false
  create_cloudwatch_agent            = false
  create_aws_for_fluentbit_resources = false
  create_loki_resources              = false
  create_mimir_resources             = false
  create_tempo_resources             = false
  parameter_vpc_id_name              = "/vpc/id"
  parameter_subnet_id1_name          = "/vpc/privatesubnet1/id"
  parameter_subnet_id2_name          = "/vpc/privatesubnet2/id"
  parameter_subnet_id3_name          = "/vpc/privatesubnet3/id"
  sns-topic                          = "arn:aws:sns:us-west-2:750713712981:eks-alarms-topic"
  external_secrets_kms_key_arns      = []
  custom_identity                    = "custom-role"
  custom_identity_associations = {
    ex-one = {
      cluster_name    = "e6bo-auto-test"
      namespace       = "custom"
      service_account = "custom"
    }
  }
}
