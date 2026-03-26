run "s3_pge_policy" {
  command = apply

  module {
    source = "./examples/s3_pge_policy"
  }
}

variables {
  aws_region      = "us-west-2"
  aws_role        = "CloudAdmin"
  kms_role        = "CloudAdmin"
  account_num     = "750713712981"
  kms_name        = "s3_pge_bucket_kms_01"
  kms_description = "ccoe-s3-pge-bucket-kms"
  grants = [
    {
      id          = null
      type        = "Group"
      permissions = ["READ"]
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
    {
      id          = null
      type        = "Group"
      permissions = ["WRITE"]
      uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
  ]
  object_lock_configuration = {
    mode  = "GOVERNANCE"
    days  = 366
    years = null
  }
  versioning = "Enabled"
  cors_rule_inputs = [{
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
    id              = null
  }]
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
}
