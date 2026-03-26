run "endpoint" {
  command = apply

  module {
    source = "./examples/endpoint"
  }
}

variables {
  name                = "my-canary"
  runtime_version     = "syn-nodejs-puppeteer-6.2"
  take_screenshot     = true
  api_hostname        = "https://www.pge.com"
  api_path            = "/en/account.html"
  frequency           = 5
  alert_sns_topic     = "arn:aws:sns:us-west-2:750713712981:canary-sns-topic"
  description         = "IAM role for AWS Synthetic Monitoring Canaries"
  aws_service         = ["lambda.amazonaws.com"]
  account_num         = "750713712981"
  aws_region          = "us-west-2"
  aws_role            = "CloudAdmin"
  bucket_name         = "canary-s3-bucket-ccoe"
  policy_name         = "canary-policy"
  comparison_operator = "LessThanThreshold"
  period              = "300" // 5 minutes (should be calculated from the frequency of the canary)
  evaluation_periods  = "1"
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  datapoints_to_alarm = "1"
  alarm_description   = "Alarm"
  threshold           = "90"
  AppID               = "1001"
  Environment         = "Dev"
  DataClassification  = "Internal"
  CRIS                = "Low"
  Notify              = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner               = ["abc1", "def2", "ghi3"]
  Compliance          = ["None"]
  Order               = 8115205
  cidr_ingress_rules = [
    {
      description      = "Allow calls from canary to HTTPS"
      from             = 443
      to               = 443
      protocol         = "TCP"
      cidr_blocks      = ["130.19.42.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]
  cidr_egress_rules = [
    {
      description      = "Allow calls from canary to DNS"
      from             = 53
      to               = 53
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "Allow calls from canary to HTTPS"
      from             = 443
      to               = 443
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      description      = "Allow calls from canary to HTTP"
      from             = 80
      to               = 80
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
  ]
}
