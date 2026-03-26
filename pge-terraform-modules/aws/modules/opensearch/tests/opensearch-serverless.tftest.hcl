# Test: Basic OpenSearch Serverless Use Case
# Description: Public access VECTORSEARCH collection with AWS-owned encryption and high availability
# This represents the simplest deployment scenario for development/testing

run "opensearch_serverless_basic" {
  command = apply

  module {
    source = "./examples/opensearch-serverless"
  }

  variables {
    # Account Configuration
    account_num = "750713712981"
    aws_region  = "us-west-2"
    aws_role    = "CloudAdmin"
    kms_role    = "TF_Developers"

    # Application Configuration
    app_prefix = "aosstest"

    # PGE Required Tags
    AppID              = "APP-1001"
    Environment        = "Dev"
    DataClassification = "Internal"
    CRIS               = "Low"
    Notify             = ["mzrk@pge.com", "r0k6@pge.com", "s7aw@pge.com"]
    Owner              = ["MZRK", "R0K6", "S7AW"]
    Compliance         = ["None"]
    Order              = 8115205
    optional_tags      = {}

    # OpenSearch Serverless Configuration - Basic Use Case
    collection_type         = "VECTORSEARCH"
    enable_standby_replicas = true  # High availability enabled
    allow_public_access     = true  # Public access for testing
    create_vpce             = false # No VPC endpoint needed
    use_ssm_for_network     = false # No SSM parameters needed

    # IAM Access Configuration
    data_access_principals = [] # Defaults to current caller
    data_access_permissions = [
      "aoss:CreateCollectionItems",
      "aoss:DeleteCollectionItems",
      "aoss:UpdateCollectionItems",
      "aoss:DescribeCollectionItems"
    ]
    index_permissions = [
      "aoss:CreateIndex",
      "aoss:DeleteIndex",
      "aoss:UpdateIndex",
      "aoss:DescribeIndex",
      "aoss:ReadDocument",
      "aoss:WriteDocument"
    ]
  }

  # Assertions to validate successful deployment
  assert {
    condition     = output.collection_id != null && output.collection_id != ""
    error_message = "Collection ID should be generated"
  }

  assert {
    condition     = output.collection_arn != null && output.collection_arn != ""
    error_message = "Collection ARN should be generated"
  }

  assert {
    condition     = output.collection_endpoint != null && output.collection_endpoint != ""
    error_message = "Collection endpoint should be available"
  }

  assert {
    condition     = output.dashboard_endpoint != null && output.dashboard_endpoint != ""
    error_message = "Dashboard endpoint should be available"
  }

  assert {
    condition     = output.collection_type == "VECTORSEARCH"
    error_message = "Collection type should be VECTORSEARCH"
  }

  assert {
    condition     = output.encryption_policy_name != null && output.encryption_policy_name != ""
    error_message = "Encryption policy should be created"
  }

  assert {
    condition     = output.network_policy_name != null && output.network_policy_name != ""
    error_message = "Network policy should be created"
  }

  assert {
    condition     = output.data_access_policy_name != null && output.data_access_policy_name != ""
    error_message = "Data access policy should be created"
  }

  assert {
    condition     = can(regex("^aosstest-[a-z0-9]{6}$", output.collection_name))
    error_message = "Collection name should follow naming convention with random suffix"
  }
}
