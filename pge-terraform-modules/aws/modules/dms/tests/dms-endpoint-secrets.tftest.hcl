run "dms-endpoint-secrets" {
  command = apply

  module {
    source = "./examples/dms-endpoint-secrets"
  }
}

variables {
  aws_region                           = "us-west-2"
  account_num                          = "750713712981"
  aws_role                             = "CloudAdmin"
  kms_role                             = "TF_Developers"
  AppID                                = "1001"
  Environment                          = "Dev"
  DataClassification                   = "Internal"
  CRIS                                 = "Low"
  Notify                               = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                = ["abc1", "def2", "ghi3"]
  Compliance                           = ["None"]
  Order                                = 8115205
  source_endpoint_id                   = "test-source-123"
  source_endpoint_engine_name          = "sqlserver"
  source_endpoint_database_name        = "m1rf-cyber"
  source_endpoint_ssl_mode             = "require"
  source_certificate_arn               = null
  target_endpoint_id                   = "test-target-123"
  target_endpoint_engine_name          = "sqlserver"
  target_endpoint_database_name        = "test-target"
  target_endpoint_ssl_mode             = "none"
  target_certificate_arn               = null
  source_endpoint_secrets_manager_arn  = "arn:aws:secretsmanager:us-west-2:750713712981:secret:test-iac-dms-exmofU"
  target_endpoint_secrets_manager_arn  = "arn:aws:secretsmanager:us-west-2:750713712981:secret:test-iac-dms-exmofU"
  kms_name                             = "test-dms-1"
  kms_description                      = "CMK for encrypting dms"
  role_service                         = ["dms.us-west-2.amazonaws.com"]
  iam_role_name                        = "test-iac-dms-tf-3"
  iam_policy_arns                      = ["arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole", "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"]
  ssm_parameter_vpc_id                 = "/vpc/id"
  ssm_parameter_subnet_id1             = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2             = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3             = "/vpc/2/privatesubnet3/id"
  replication_subnet_group_description = "Test replication subnet group"
  replication_subnet_group_id          = "test-dms-replication-subnet-group-tf"
  role_name_access_endpoint            = "dms_roleaccess_for_endpoint"
  role_name_cloudwatch_logs            = "dms_role_cloudwatch_logs"
  role_name_vpc                        = "dms_role_vpc"
  sg_name_replication_instance         = "sg_dms"
  sg_description_replication_instance  = "security group for DMS"
  cidr_egress_rules_replication_instance = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  cidr_ingress_rules_replication_instance = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE ingress rules"
  }]
  instance_allocated_storage           = 20
  instance_allow_major_version_upgrade = false
  instance_apply_immediately           = true
  instance_version_upgrade             = true
  instance_availability_zone           = "us-west-2c"
  instance_engine_version              = "3.5.3"
  instance_multi_az                    = false
  instance_preferred_maintenance       = "sun:10:30-sun:14:30"
  instance_publicly_accessible         = false
  instance_replication_instance_class  = "dms.t3.medium"
  instance_replication_id              = "test-replication-instance-dms"
  migration_type                       = "full-load"
  replication_task_id                  = "test-iac-tf-1"
  snstopic_name                        = "sns_topic_test"
  snstopic_display_name                = "CloudCOE_snstopic"
  event_enabled                        = true
  event_categories                     = ["creation", "failure"]
  event_name                           = "dms-event-subscription-one"
  source_ids                           = ["test-replication-instance-dms"]
  source_type                          = "replication-instance"
}
