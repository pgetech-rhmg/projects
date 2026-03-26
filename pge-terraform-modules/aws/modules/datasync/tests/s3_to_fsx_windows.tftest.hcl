run "s3_to_fsx_windows" {
  command = apply

  module {
    source = "./examples/s3_to_fsx_windows"
  }
}

variables {
  account_num              = "514712703977"
  aws_region               = "us-west-2"
  aws_role                 = "CloudAdmin"
  AppID                    = "1001"
  Environment              = "Dev"
  DataClassification       = "Internal"
  CRIS                     = "Low"
  Notify                   = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                    = ["abc1", "def2", "ghi3"]
  Compliance               = ["None"]
  Order                    = 8115205
  task_name                = "ccoe-s3-to-fsx_windows"
  s3_role_name             = "s3_datasync_access_role"
  aws_service              = ["datasync.amazonaws.com"]
  bucket_name              = "ccoe-test-datasync-bucket"
  s3_location_subdirectory = "my-subdirectory"
  fsx_location_arn         = "arn:aws:fsx:us-west-2:514712703977:file-system/fs-005770afa99688362"
  domain                   = null
  fsx_user                 = "rzhk"
  fsx_password             = "rzhk1"
}
