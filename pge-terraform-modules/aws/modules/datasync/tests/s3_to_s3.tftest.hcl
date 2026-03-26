run "s3_to_s3" {
  command = apply

  module {
    source = "./examples/s3_to_s3"
  }
}

variables {
  account_num                       = "750713712981"
  aws_region                        = "us-west-2"
  aws_role                          = "CloudAdmin"
  AppID                             = "1001"
  Environment                       = "Dev"
  DataClassification                = "Internal"
  CRIS                              = "Low"
  Notify                            = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                             = ["abc1", "def2", "ghi3"]
  Compliance                        = ["None"]
  Order                             = 8115205
  task_name                         = "ccoe-s3-to-s3"
  s3_role_name                      = "s3_datasync_access_role"
  aws_service                       = ["datasync.amazonaws.com"]
  source_bucket_name                = "ccoe-test-datasync-source"
  destination_bucket_name           = "ccoe-test-datasync-destination"
  source_location_subdirectory      = "my-subdirectory"
  destination_location_subdirectory = "my-subdirectory"
  posix_permissions                 = "NONE"
  gid                               = "NONE"
  uid                               = "NONE"
}
