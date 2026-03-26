run "glue_job" {
  command = apply

  module {
    source = "./examples/glue_job"
  }
}

variables {
  aws_region         = "us-west-2"
  account_num        = "056672152820"
  aws_role           = "CloudAdmin"
  kms_role           = "TF_Developers"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
  name               = "test-iac-glue-tf-1"
  glue_job_command = [
    {
      "script_location" = "s3://test-iac-s3-bucket/glue_script.py"
    }
  ]
  availability_zone                           = "us-west-2a"
  role_service                                = ["glue.amazonaws.com"]
  iam_policy_arns                             = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  glue_connection_type                        = "NETWORK"
  glue_dev_endpoint_extra_jars_s3_path        = "s3://test-iac-s3-bucket/read"
  glue_dev_endpoint_extra_python_libs_s3_path = "s3://test-iac-s3-bucket/read"
  glue_dev_endpoint_glue_version              = "0.9"
  glue_dev_endpoint_worker_type               = "G.1X"
  glue_dev_endpoint_number_of_nodes           = null
  glue_dev_endpoint_number_of_workers         = 5
  glue_dev_endpoint_public_key                = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDvHkR3SpJUyFwVHGUtYd1cGWpZlq/k4uAsQ0/hbwhD4aA+7j93YKbfUfdCxNzOiceKwnUfBjLlmn/S5iA2ez2fSC2Uuhuj/Xdnv6k/bzm4HCX/mr5dD5yByGr8JudITp3EByILSW/PS4yOHSXXxx/JWGLkm6j0e6E2H0GgnaNJEgkU4xZ4QLeKGP7a2RDlT+2oQpLqw+pwXZIQ+Msj9UW8vsAnUbpuTqPkbLLA2YdX781iDJGKtL0eH6uK5E3DpsvRX/IZAR3sVRiTgKr9WebOVcBBmaHtr9yKUlIXpxHTo+B023vTElr3Y4X3jjN1W0RCq31Dsj9WuGc5P9THCks/tF0i9v7AgaT0rcyAX5alDGJcF1+4rIpX1gH+LiA3GPG/GszF11aKBypuvCVWuwBJeiI3KWX6JbMLF0F/ZQppge/DbwD+pVeJnx7IVLLRFCbWX+AZIqicGgKZ/NsgiMnOR1HgaeSbx9y2k9ja3zEOUlv/dL/y0v1aWfenVOmdnM= abc@pge.com"
  glue_dev_endpoint_public_keys               = []
  glue_dev_endpoint_arguments = {
    "GLUE_PYTHON_VERSION" = "2"
  }
  ssm_parameter_vpc_id     = "/vpc/id"
  ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
  cidr_blocks              = ["0.0.0.0/0"]
  glue_trigger_type        = "CONDITIONAL"
  glue_trigger_predicate = [{
    job_name = "test123"
    state    = "FAILED"
  }]
}
