variable "poll_rate" {
  type = map(any)
  default = {
    "Dev" = {
      "rate" = "rate(5 minutes)"
    }
    "QA" = {
      "rate" = "rate(5 minutes)"
    }
    "Prod" = {
      "rate" = "rate(5 minutes)"
    }
  }
}

variable "tags" {
  description = "A map of tags passed in during deployment"
  type        = map(any)
}

variable "prefix" {
  description = "The prefix prepended to resource names"
  type        = string
  default     = "engage"
}

variable "git_branch" {
  description = "The git branch to deploy from"
  type        = string
}
