# Implement Sumologic ingestion using AWs Kinesis-Firehose
# see https://help.sumologic.com/docs/send-data/hosted-collectors/amazon-aws/aws-kinesis-firehose-logs-source/#create-an-aws-kinesis-firehose-for-logssource

locals {
  function_name = basename(var.log_group_name)
}
  
data "aws_iam_role" "firehose_role" {
  name = "mrad-sumo-firehose-role"
}

# --- CloudWatch Log Subscription to Firehose ---
resource "aws_cloudwatch_log_subscription_filter" "sumo_firehose" {
  name            = "mrad-sumo-firehose-${local.function_name}"
  log_group_name  = var.log_group_name
  # If filter_pattern is set to an empty string (""), all log events from the log group are forwarded.
  # If you specify a pattern, only log events matching that pattern will be sent to the destination.
  filter_pattern  = ""
  destination_arn = data.aws_kinesis_firehose_delivery_stream.sumo_firehose.arn
  role_arn        = data.aws_iam_role.firehose_role.arn
  # Explicit dependency to ensure Firehose data source is evaluated first
  depends_on = [
    data.aws_kinesis_firehose_delivery_stream.sumo_firehose,
    data.aws_iam_role.firehose_role
  ]
}

# Fetch Firehose stream name from SSM Parameter Store
# (created in mrad-shared-infra)
data "aws_ssm_parameter" "sumo_firehose_stream_name" {
  name = "/mrad/sumo_firehose_stream_name"
}

# Fetch the Firehose ARN using the stream name from SSM
# (Assumes the stream is in the same account/region)
data "aws_kinesis_firehose_delivery_stream" "sumo_firehose" {
  name = data.aws_ssm_parameter.sumo_firehose_stream_name.value
}
