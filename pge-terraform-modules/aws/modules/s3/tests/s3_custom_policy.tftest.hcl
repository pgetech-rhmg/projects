run "s3_custom_policy" {
  command = apply

  module {
    source = "./examples/s3_custom_policy"
  }
}

variables {
  aws_region               = "us-west-2"
  kms_role                 = "CloudAdmin"
  account_num              = "750713712981"
  aws_role                 = "CloudAdmin"
  bucket_name              = "ccoe-s3-custom-bucket-test-pge"
  kms_name                 = "s3_bucket_kms_01"
  kms_description          = "ccoe-s3-bucket-kms"
  AppID                    = "1001"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["None"]
  Order                    = 8115205
  intelligent_tiering_name = "ccoe-intelligent-tiering-test-pge"
  deeparchive_days         = 180
  archive_days             = 90
}
