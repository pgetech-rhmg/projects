run "domain" {
  command = apply

  module {
    source = "./examples/domain"
  }
}

variables {
  account_num               = "750713712981"
  aws_region                = "us-west-2"
  aws_role                  = "CloudAdmin"
  AppID                     = "1001"
  Environment               = "Dev"
  DataClassification        = "Internal"
  CRIS                      = "Low"
  Notify                    = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                     = ["abc1", "def2", "ghi3"]
  Compliance                = ["None"]
  optional_tags             = { "service" = "opensearch" }
  domain_name               = "pgeos-test-a8tq"
  engine_version            = "OpenSearch_2.11"
  advanced_options          = {}
  Order                     = 8115205
  advanced_security_options = [{ "enabled" = true }]
  cluster_config = [{ instance_type = "r6g.large.search",
    instance_count         = 3,
    cold_storage_options   = { enabled = false },
    zone_awareness_enabled = true,
    zone_awareness_config  = { availability_zone_count = 3 }
  }]
  ebs_options            = [{ ebs_enabled = true }]
  log_publishing_options = []
  domain_endpoint_options = [{ "enforce_https" = true,
    "tls_security_policy" = "Policy-Min-TLS-1-2-2019-07"
  }]
  encrypt_at_rest_options         = [{ enabled = true, kms_key_id = null }]
  node_to_node_encryption_options = [{ enabled = true }]
  vpc_options = [{ security_group_ids = ["sg-0a619befd8c9e904c"],
    subnet_ids = ["subnet-0b355e06930ad626c", "subnet-0c02015de7dc8232c", "subnet-0fcaeb67c4d490357"]
  }]
  security_group_ids = ["sg-0a619befd8c9e904c"]
  subnet_ids         = ["subnet-0ce9bc280b58f1c60"]
}

