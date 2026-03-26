run "emr_serverless_hive" {
  command = apply

  module {
    source = "./examples/emr_serverless_hive"
  }
}

variables {
  account_num          = "750713712981"
  aws_region           = "us-west-2"
  aws_role             = "CloudAdminNonProdAccess"
  AppID                = "1001"
  Environment          = "Dev"
  DataClassification   = "Internal"
  CRIS                 = "Low"
  Notify               = ["mzrk@pge.com", "r0k6@pge.com", "s7aw@pge.com"]
  Owner                = ["mzrk", "rok6", "s7aw"]
  Compliance           = ["None"]
  Order                = 8115205
  subnet_id1_name      = "/vpc/2/privatesubnet1/id"
  subnet_id2_name      = "/vpc/2/privatesubnet2/id"
  subnet_id3_name      = "/vpc/2/privatesubnet3/id"
  name                 = "ccoe-test"
  release_label_prefix = "emr-6"
  type                 = "hive"
  initial_capacity = {
    driver = {
      initial_capacity_type = "HiveDriver"
      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "2 vCPU"
          memory = "6 GB"
        }
      }
    }
    task = {
      initial_capacity_type = "TezTask"
      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "4 vCPU"
          memory = "16 GB"
          disk   = "20 GB"
        }
      }
    }
  }
  maximum_capacity = {
    cpu    = "24 vCPU"
    memory = "72 GB"
  }
}
