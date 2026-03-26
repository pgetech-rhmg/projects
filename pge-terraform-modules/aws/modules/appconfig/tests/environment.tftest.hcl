run "environment" {
  command = apply

  module {
    source = "./examples/environment"
  }
}

variables {
  account_num        = "750713712981"
  aws_region         = "us-west-2"
  aws_role           = "CloudAdmin"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  name               = "nonprod"
  description        = "A well thought out description of the environment."
  application_id     = "3jcwgsa"
  monitors = [
    {
      alarm_arn      = "arn:aws:cloudwatch:us-west-2:750713712981:alarm:TargetTracking-springapp-aicg-asg-ecs-ec2-AlarmLow-12e28ff6-3e7a-469c-93e6-3f5ca7707f8b"
      alarm_role_arn = "arn:aws:iam::750713712981:role/CloudAdmin"
    },
    {
      alarm_arn      = "arn:aws:cloudwatch:us-west-2:750713712981:alarm:TargetTracking-springapp-aicg-asg-ecs-ec2-AlarmHigh-0a0dc473-be61-4dcb-9975-0ba855424671"
      alarm_role_arn = "arn:aws:iam::750713712981:role/CloudAdmin"
    }
  ]
}
