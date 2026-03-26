run "s3_time_replication" {
  command = apply

  module {
    source = "./examples/s3_time_replication"
  }
}

variables {
  aws_region              = "us-west-2"
  account_num             = "750713712981"
  aws_role                = "CloudAdmin"
  kms_role                = "CloudAdmin"
  versioning              = "Enabled"
  kms_name                = "s3_tr_bucket_kms"
  kms_description         = "ccoe-s3-tr-bucket-kms"
  source_bucket_name      = "ccoe-s3-tr-bucket"
  destination_bucket_name = "ccoe-s3-trd-bucket"
  iam_resource            = "tf-iam-role-replication"
  AppID                   = "1001"
  Environment             = "Dev"
  DataClassification      = "Internal"
  CRIS                    = "Low"
  Notify                  = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                   = ["abc1", "def2", "ghi3"]
  Compliance              = ["None"]
  Order                   = 8115205
}
