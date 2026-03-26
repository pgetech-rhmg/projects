run "rds_sqlserver_from_snapshot" {
  command = apply

  module {
    source = "./examples/rds_sqlserver_from_snapshot"
  }
}

variables {
  aws_role                             = "CloudAdmin"
  kms_role                             = "CloudAdmin"
  kms_name                             = "ccoe-rds-sqlserver-kms"
  account_num                          = "750713712981"
  aws_region                           = "us-west-2"
  user                                 = "rb1c"
  identifier                           = "sqlserver"
  multi_az                             = true
  monitoring_interval                  = 60
  allocated_storage                    = "20"
  storage_type                         = "gp2"
  engine_version                       = "15.00"
  engine                               = "sqlserver-ee"
  family                               = "sqlserver-ee-15.0"
  license_model                        = "license-included"
  instance_class                       = "db.t3.xlarge"
  timezone                             = "UTC"
  snapshot_identifier                  = "rds:sqlserver-paj4a-2023-11-03-18-47"
  allow_major_version_upgrade          = true
  username                             = "admin"
  manage_master_user_password          = true
  maintenance_window                   = "sun:20:00-sun:21:00"
  backup_window                        = "11:00-12:00"
  max_allocated_storage                = 200
  cpu_credit_balance_too_low_threshold = 150
  tags = {
    Owner              = "abc1_def2_ghi3"
    AppID              = "APP-1001"
    Environment        = "Dev"
    DataClassification = "Internal"
    Compliance         = "None"
    CRIS               = "High"
    Notify             = "abc1@pge.com_def2@pge.com_ghi3@pge.com"
    Order              = 8115205
  }
  /***************************************security group ********************************************************/
  cidr_ingress_rules = [
    {
      from             = 1433,
      to               = 1433,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.112.128/25"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "RDS Ingress rule 1"
    },
    {
      from             = 1433,
      to               = 1433,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.112.192/27"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "RDS Ingress rule 2"
    },
    {
      from             = 1433,
      to               = 1433,
      protocol         = "tcp",
      cidr_blocks      = ["10.90.112.160/27"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "RDS Ingress rule 3"
    }
  ]
  cidr_egress_rules = [
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["10.90.112.128/25"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "RDS egress rule 1"
    },
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["10.90.112.192/27"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "RDS egress rule 2"
    },
    {
      from             = 0,
      to               = 0,
      protocol         = "-1",
      cidr_blocks      = ["10.90.112.160/27"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "RDS egress rule 3"
    }
  ]
}
