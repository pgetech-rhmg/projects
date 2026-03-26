
data "aws_s3_bucket" "s3_canaries-reports" {
  bucket = var.reports-bucket
}


data "aws_region" "current" {
}