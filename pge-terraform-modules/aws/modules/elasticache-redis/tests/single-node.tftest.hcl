run "single-node" {
  command = apply

  module {
    source = "./examples/single-node"
  }
}

variables {
  aws_region                              = "us-west-2"
  account_num                             = "750713712981"
  aws_role                                = "CloudAdmin"
  AppID                                   = "1001"
  Environment                             = "Dev"
  DataClassification                      = "Internal"
  CRIS                                    = "Low"
  Notify                                  = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                                   = ["abc1", "def2", "ghi3"]
  Compliance                              = ["None"]
  Order                                   = 8115205
  cluster_id                              = "replication-62"
  node_type                               = "cache.m4.large"
  redis_engine_version                    = "6.x"
  snapshot_retention                      = 21
  final_snapshot                          = null
  maintenance_window                      = "sun:05:00-sun:09:00"
  snapshot_window                         = "01:00-02:00"
  slow_logs_log_delivery_destination      = "test-data-123"
  slow_logs_log_delivery_destination_type = "kinesis-firehose"
  slow_logs_log_delivery_log_format       = "json"
  ssm_parameter_name_vpc_id               = "/vpc/2/id"
  ssm_parameter_name_private_subnet1      = "/vpc/2/privatesubnet1/id"
  ssm_parameter_name_private_subnet2      = "/vpc/2/privatesubnet2/id"
  sg_name                                 = "replication62"
  sg_description                          = "Security group for example usage with redis"
  cidr_ingress_rules = [{
    from             = 2049,
    to               = 2049,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.0/25", "10.90.232.0/23"]
    ipv6_cidr_blocks = []
    description      = "CCOE Ingress rules"
    prefix_list_ids  = []
    }
  ]
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    description      = "CCOE egress rules"
    prefix_list_ids  = []
  }]
}
