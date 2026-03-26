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

vpc_id          = "/vpc/id"
subnet_id1_name = "/vpc/2/privatesubnet1/id"
subnet_id2_name = "/vpc/2/privatesubnet2/id"
subnet_id3_name = "/vpc/2/privatesubnet3/id"

##### EMR variables #####
name = "ccoe-emr"

release_label_filters = {
    emr6 = {
      prefix = "emr-6"
    }
  }

applications = ["spark", "trino"]

auto_termination_policy = {
    idle_timeout = 3600
  }

  bootstrap_action = [
    {
      path = "file:/bin/echo",
      name = "Just an example",
      args = ["Hello World!"]
    }
  ]

configurations_json = <<EOT
[
  {
    "Classification": "spark-env",
    "Configurations": [
      {
        "Classification": "export",
        "Properties": {
          "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
        }
      }
    ],
    "Properties": {}
  }
]
EOT

master_instance_fleet = {
    name                      = "master-fleet"
    target_on_demand_capacity = 1
    instance_type_configs = [
    {
        instance_type = "m5.xlarge"
    }
    ]
}

core_instance_fleet = {
    name                      = "core-fleet"
    target_on_demand_capacity = 2
    instance_type_configs = [
    {
        instance_type     = "m5.xlarge"
        weighted_capacity = 1
        ebs_config = [
        {
            size                 = 64
            type                 = "gp3"
            volumes_per_instance = 1
        }
        ]
    }
    ]
}

# Commenting out task fleet to simplify initial deployment
# task_instance_fleet = {
#     name                      = "task-fleet"
#     target_spot_capacity      = 1
#     instance_type_configs = [
#     {
#         instance_type     = "c4.large"
#         weighted_capacity = 1
#         ebs_config = [
#         {
#             size                 = 256
#             type                 = "gp3"
#             volumes_per_instance = 1
#         }
#         ]
#     }
#     ]
# }

ebs_root_volume_size = 64
keep_job_flow_alive_when_no_steps = true
list_steps_states = ["PENDING", "RUNNING", "CANCEL_PENDING", "CANCELLED", "FAILED", "INTERRUPTED", "COMPLETED"]
scale_down_behavior = "TERMINATE_AT_TASK_COMPLETION"
step_concurrency_level = 2
termination_protection     = false
unhealthy_node_replacement = true
visible_to_all_users = true

##### VPC Endpoint variables #####
  ### S3 Endpoint ####
service_name_s3   = "com.amazonaws.us-west-2.s3"
route_table_ids = ["rtb-02b58d41c08ef6e9f"]

  ### EMR Endpoint ###
service_name_emr = "com.amazonaws.us-west-2.elasticmapreduce"
private_dns_enabled_emr = true

  ### STS Endpoint ###
service_name_sts = "com.amazonaws.us-west-2.sts"
private_dns_enabled_sts = true

##### EMR service role additional policies #####
service_iam_role_policies = {
  "AmazonEC2FullAccess" = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
##### EMR instance profile additional policies (for KMS access) #####
iam_instance_profile_policies = {
  "AmazonElasticMapReduceforEC2Role" = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
  "AWSKeyManagementServicePowerUser" = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}
