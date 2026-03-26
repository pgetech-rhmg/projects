output "eks-cloudwatch-dashboard-arn" {
  value = aws_cloudwatch_dashboard.main[*].dashboard_arn

}


output "eks-cloudwatch-dashboard-arn-all" {
  value = aws_cloudwatch_dashboard.main

}

