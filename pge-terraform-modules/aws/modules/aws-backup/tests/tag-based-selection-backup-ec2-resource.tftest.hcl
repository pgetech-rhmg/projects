run "tag-based-selection-backup-ec2-resource" {
  command = apply

  module {
    source = "./examples/tag-based-selection-backup-ec2-resource"
  }
}

variables {
  account_num                = "750713712981"
  aws_region                 = "us-west-2"
  aws_role                   = "CloudAdmin"
  kms_role                   = "CloudAdmin"
  AppID                      = "1001"
  Environment                = "Dev"
  DataClassification         = "Internal"
  CRIS                       = "Low"
  Notify                     = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                      = ["abc1", "def2", "ghi3"]
  Compliance                 = ["None"]
  Order                      = 8115205
  optional_tags              = { pge_team = "ccoe-tf-developers" }
  vault_name                 = "vault-webapp"
  create_vault_notifications = true
  backup_vault_events        = ["BACKUP_JOB_COMPLETED"]
  aws_backup_plan_name       = "backup-plan-webapp-tag-based"
  aws_backup_plan_rule = [
    {
      rule_name         = "backup-plan-rule-tag-based"
      target_vault_name = "vault-webapp"
      schedule          = "cron(0 12 * * ? *)"
      start_window      = "60"
      completion_window = "120"
      lifecycle = {
        delete_after = 5
      }
  }]
  backup_selection_name = "backup-selection-tag-based"
  aws_service           = ["backup.amazonaws.com"]
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "application"
      value = "ccoe-web-app"
    }
  ]
  kms_key               = "aws-backup-webapp-kms"
  kms_description       = "The description of the key as viewed in AWS console."
  custom_kms_file       = "kms_user_policy.json"
  vpc_id_name           = "/vpc/id"
  subnet_id1_name       = "/vpc/2/privatesubnet1/id"
  golden_ami_name       = "/ami/linux/golden"
  aws_backup_tags       = { application = "ccoe-web-app" }
  ebs_availability_zone = "us-west-2a"
  ebs_size              = 8
  ebs_type              = "gp2"
  ebs_device_name       = "/dev/sdh"
  ec2_name              = "ec2test-aws-backup-test-aicg"
  ec2_instance_type     = "t2.micro"
  ec2_az                = "us-west-2a"
  sg_name               = "ebs-sg-aws-backup-test-aicg"
  sg_description        = "Security group for example usage with EBS"
  cidr_ingress_rules = [{
    from             = 5701,
    to               = 5703,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.195.128/25"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = ["10.90.108.0/23"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  snstopic_name         = "sns-aws-backup-tag-based"
  snstopic_display_name = "sns-aws-backup-tag-based"
  endpoint              = ["aicg@pge.com"]
  protocol              = "email"
  sns_policy_file_name  = "sns_access_policy.json"
}
