variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}
variable "replication_configuration" {
  description = "Map containing cross-region replication configuration."
  type        = any
}