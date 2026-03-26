// Caller Identity
data "aws_ssm_parameter" "vpc_id" {
  name = var.parameter_vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.parameter_subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.parameter_subnet_id2_name
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.parameter_subnet_id3_name
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}
