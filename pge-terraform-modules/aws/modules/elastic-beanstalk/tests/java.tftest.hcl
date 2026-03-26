run "java" {
  command = apply

  module {
    source = "./examples/java"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["SOX", "HIPAA"]
  Order              = 8115205
  optional_tags = {
    managed_by = "terraform"
  }
  name                                   = "java-example"
  ssm_parameter_vpc_id                   = "/vpc/id"
  ssm_parameter_subnet_id1               = "/vpc/2/privatesubnet1/id"
  ssm_parameter_subnet_id2               = "/vpc/2/privatesubnet2/id"
  ssm_parameter_subnet_id3               = "/vpc/2/privatesubnet3/id"
  ssm_parameter_golden_ami_id            = "/ami/linux/golden"
  max_count                              = 128
  delete_source_from_s3                  = true
  path                                   = "/"
  aws_service                            = ["elasticbeanstalk.amazonaws.com", "ec2.amazonaws.com"]
  policy_arns                            = ["arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker", "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"]
  bucket_object_key                      = "beanstalk/s3_object_tomcat.zip"
  environment_solution_stack_name        = "64bit Amazon Linux 2023 v5.1.0 running Tomcat 9 Corretto 17"
  template_file_name                     = "s3_alb_logs_policy.json"
  secretsmanager_db_password_secret_name = "secretsmanager_db_password:dbpassword"
  db_engine                              = "mysql"
  db_version                             = "8.0.36"
  rds                                    = true
  application_version_force_delete       = "true"
  application_version_source_zip         = "tomcat.zip"
  application_version                    = "v1.0.0"
  acm_domain_name                        = "nonprod.pge.com"
  organization                           = "ACME Examples, Inc"
  private_key_algorithm                  = "RSA"
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  validity_period_hours = 12
}
