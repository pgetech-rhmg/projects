run "emr_serverless_spark" {
  command = apply

  module {
    source = "./examples/emr_serverless_spark"
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
  Notify               = ["mzrk@pge.com", "rok6@pge.com", "s7aw@pge.com"]
  Owner                = ["mzrk", "rok6", "s7aw"]
  Compliance           = ["None"]
  Order                = 8115205
  subnet_id1_name      = "/vpc/2/privatesubnet1/id"
  subnet_id2_name      = "/vpc/2/privatesubnet2/id"
  subnet_id3_name      = "/vpc/2/privatesubnet3/id"
  name                 = "ccoe-test"
  release_label_prefix = "emr-6"
  type                 = "spark"
  initial_capacity = {
    driver = {
      initial_capacity_type = "Driver"
      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "4 vCPU"
          memory = "16 GB"
        }
      }
    }
    executor = {
      initial_capacity_type = "Executor"
      initial_capacity_config = {
        worker_count = 2
        worker_configuration = {
          cpu    = "8 vCPU"
          memory = "24 GB"
          disk   = "64 GB"
        }
      }
    }
  }
  interactive_configuration = {
    livy_endpoint_enabled = true
    studio_enabled        = true
  }
  maximum_capacity = {
    cpu    = "48 vCPU"
    memory = "144 GB"
  }
}
