##### General configuration #####
account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
AppID       = "1001"
Environment = "Dev" # Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal" # Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"      # Cyber Risk Impact Score High, Medium, Low (only one)
Notify             = ["mzrk@pge.com", "rok6@pge.com", "s7aw@pge.com"]
Owner              = ["mzrk", "rok6", "s7aw"] # List three owners of the system, as defined by AMPS Director, Client Owner and IT Leader
Compliance         = ["None"]
Order              = 8115205 # Order must be between 7 and 9 digits

###### VPC configuration #####

subnet_id1_name = "/vpc/2/privatesubnet1/id"
subnet_id2_name = "/vpc/2/privatesubnet2/id"
subnet_id3_name = "/vpc/2/privatesubnet3/id"

###### EMR configuration #####

name  = "ccoe-test"
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

monitoring_configuration = {
  cloudwatch_logging_configuration = {
    enabled                = true
  }
}



