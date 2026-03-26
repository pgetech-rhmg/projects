run "complete-log-metric-filter-and-alarm" {
  command = apply

  module {
    source = "./examples/complete-log-metric-filter-and-alarm"
  }
}

variables {
  account_num                   = "750713712981"
  aws_region                    = "us-west-2"
  aws_role                      = "CloudAdmin"
  MetricTransformationName      = "ErrorCount"
  MetricTransformationNamespace = "MyAppNamespace"
  AppID                         = "1001"
  Environment                   = "Dev"
  DataClassification            = "Internal"
  CRIS                          = "Low"
  Notify                        = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                         = ["abc1", "def2", "ghi3"]
  Compliance                    = ["None"]
  Order                         = 8115205
  LogGroupNamePrefix            = "ccoe-tfc"
  LogMetricFilterPattern        = "ERROR"
  AlarmDescription              = "Log errors are too high"
  AlarmComparisonOperator       = "GreaterThanOrEqualToThreshold"
  AlarmEvaluationPeriods        = 1
  AlarmThreshold                = 10
  AlarmPeriod                   = 60
  AlarmUnit                     = "Count"
  AlarmStatistic                = "Sum"
}
