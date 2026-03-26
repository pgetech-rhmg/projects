variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

variable "suffix" {
  description = "String appended to resource names to keep instances separate"
  type        = string
}

variable "repo_name" {
  type        = string
  description = "The repository to build and deploy. This name must match the repository name or GitHub EXACTLY."

  validation {
    condition     = anytrue([
      var.repo_name == "Engage-Webapp",
      var.repo_name == "Img-Viewer"
    ])
    error_message = "The repo_name variable must be either Engage-Webapp or Img-Viewer."
  }
}

variable "git_branch" {
  type        = string
  description = "The git branch of the repository to build and deploy. Examples: dev, qa, freeze, pilot, main"
}

variable "node_env" {
  type        = string
  description = "The node environment to use for builds. Examples: predev, dev, qa, freeze, pilot, blue, or green"
}

variable "s3_bucket_id" {
  type        = string
  description = "The S3 bucket to use for storing build artifacts"
}

variable "cloudfront_distribution_id" {
  type        = string
  description = "The CloudFront distribution ID to use for the application"
}