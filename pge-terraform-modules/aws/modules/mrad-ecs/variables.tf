variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to these resources which indicates their provenance."
  default     = {}
}

variable "project_name" {
  type        = string
  description = "The name of the project."
}

variable "branch" {
  type        = string
  description = "The name of the git branch this CodePipeline is configured to build. Usually you should set this to `var.TFC_CONFIGURATION_VERSION_GIT_BRANCH`. See: https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment"
}

variable "aws_role" {
  type        = string
  description = "The AWS role used for the Sumo logger module."
}

variable "task_names" {
  type        = list(any)
  description = "If more than one task, associated service and ecr repo is need then use a list of names to create multiple. It gets converted to a Set, e.g. [\"Asset360\", \"Public\", \"Cache\"]."
  default     = ["ECS"]
}

variable "entry_point" {
  type        = list(string)
  description = "The entry point for the container."
  default = [
    "bash",
    "run.sh"
  ]
}

variable "port" {
  type        = number
  description = "The port on which the application code is listening for HTTP requests."
  default     = 8080
}

variable "task_cpu" {
  type        = number
  description = "CPU configuration for this ECS task. 1024 = 1 vCPU. See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = 512
}

variable "task_memory" {
  type        = number
  description = "Memory configuration for this ECS task. 1024 = 1024 MiB. See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = 1024
}

variable "ulimit_nofile_soft" {
  type        = number
  description = "The `ulimit` soft limit for the number of file descriptors. See: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_Ulimit.html"
  default     = "1024"
}

variable "ulimit_nofile_hard" {
  type        = number
  description = "The `ulimit` hard limit for the number of file descriptors. See: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_Ulimit.html"
  default     = "4096"
}

variable "health_check_path" {
  type        = string
  description = "Path for the HTTP health check used to determine if the container is healthy."
  default     = "/."
}

variable "health_check_timeout" {
  type        = number
  description = "Amount of time, in seconds, during which no response from a target means a failed health check, from 2 to 120 seconds."
  default     = 5
}

variable "healthcheck_enabled" {
  type        = bool
  description = "If false, disables the ECS task health check for the container."
  default     = true
}

variable "additional_security_groups" {
  type        = list(string)
  description = "Any additional security groups to be added to ECS."
  default     = []
}

variable "aws_account" {
  type        = string
  description = "The name of the AWS account or environment. Should be one of: `Dev`, `Test`, `QA`, `Prod`"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to use for storing logs."
}

variable "lb" {
  type        = bool
  description = "If true, provision a AWS ALB for this ECS instance."
  default     = false
}

variable "force_lb" {
  type        = bool
  description = "If true, force creation of Route53 DNS record regardless of branch restrictions. Overrides the default behavior that only creates DNS records for development, master, main, or production branches."
  default     = false
}

variable "partner" {
  type        = string
  description = "The name of the partner team that owns this pipeline."
  default     = "MRAD"
}

variable "subnet_qualifier" {
  type        = map(any)
  description = "If `partner = MRAD`, this is used to select a subnet by environment."
  default     = { Dev = "Dev-2", Test = "Test-2", QA = "QA-2", Prod = "Prod-2" }
}

variable "vpc" {
  type        = string
  description = "If `partner` is not MRAD, the name of the VPC to use for each CodeBuild step."
  default     = ""
}

variable "ecs_subnet1" {
  type        = string
  description = "The name of the first subnet to use for the ECS service."
  default     = ""
}

variable "ecs_subnet2" {
  type        = string
  description = "The name of the second subnet to use for the ECS service."
  default     = ""
}

variable "ecs_subnet3" {
  type        = string
  description = "The name of the third subnet to use for the ECS service."
  default     = ""
}

variable "subnet1" {
  type        = string
  description = "The name of the first subnet to use for the ALB."
  default     = ""
}

variable "subnet2" {
  type        = string
  description = "The name of the second subnet to use for the ALB."
  default     = ""
}

variable "subnet3" {
  type        = string
  description = "The name of the third subnet to use for the ALB."
  default     = ""
}

variable "domain" {
  type        = string
  description = "The base domain name to be used for ALB and ACM. For non-prod environments (not QA or Prod) you should generally set this to `nonprod.pge.com`."
  default     = "dc.pge.com"
}

variable "lifecycle_policy" {
  description = "The document for the ECR lifecycle policy."
  type        = string
  default     = <<-EOT
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Keep last 3 tagged images",
                "selection": {
                    "tagStatus": "any",
                    "countType": "imageCountMoreThan",
                    "countNumber": 3
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
  EOT

  validation {
    condition     = can(jsondecode(var.lifecycle_policy))
    error_message = "The provided `var.lifecycle_policy` was not valid JSON."
  }
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "additional_task_iam_policy" {
  description = "An optional additional IAM policy to attach to the task role"
  type        = string
  default     = null

  validation {
    condition     = var.additional_task_iam_policy == null || can(jsondecode(var.additional_task_iam_policy))
    error_message = "The provided `var.additional_task_iam_policy` was not valid JSON."
  }
}

variable "filter_pattern" {
  type        = string
  description = "The CloudWatch Logs filter pattern for pattern matching logs to send to Sumo Logic. Applies to an `aws_cloudwatch_log_subscription_filter`. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter#filter_pattern"
  default     = ""
}

variable "balancer_port" {
  type        = string
  description = "The port on which the load balancer listens."
  default     = 443
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "The minimum percentage of running instances this ECS service requires to be healthy during a deployment."
  default     = "100"
}

variable "deployment_maximum_percent" {
  type        = number
  description = "The maximum percentage of running instances this ECS service allows during a deployment (i.e. surge deployment)."
  default     = "200"
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling for ECS services"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for autoscaling"
  type        = number
  default     = 1
  validation {
    condition     = var.autoscaling_min_capacity >= 1
    error_message = "Minimum capacity must be at least 1."
  }
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for autoscaling"
  type        = number
  default     = 3
  validation {
    condition     = var.autoscaling_max_capacity >= 1
    error_message = "Maximum capacity must be at least 1."
  }
}

variable "autoscaling_target_cpu" {
  description = "Target CPU utilization percentage for autoscaling"
  type        = number
  default     = 70
  validation {
    condition     = var.autoscaling_target_cpu > 0 && var.autoscaling_target_cpu <= 100
    error_message = "Target CPU must be between 1 and 100."
  }
}

variable "autoscaling_scale_in_cooldown" {
  description = "Time (in seconds) to wait before allowing scale-in operations"
  type        = number
  default     = 60
}

variable "autoscaling_scale_out_cooldown" {
  description = "Time (in seconds) to wait before allowing scale-out operations"
  type        = number
  default     = 60
}

variable "availability_zone_rebalancing" {
  description = "Automatically redistributes tasks within a service across Availability Zones. Valid values: ENABLED, DISABLED. Default: DISABLED."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = can(regex("^(ENABLED|DISABLED)$", var.availability_zone_rebalancing))
    error_message = "The availability_zone_rebalancing value must be either 'ENABLED' or 'DISABLED'."
  }
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Secrets to inject as env vars from Secrets Manager. Each `valueFrom` is a secret ARN, optionally with `:JSON_KEY::` suffix to extract a single key."
  default     = []

  validation {
    condition     = alltrue([for s in var.secrets : length(trimspace(s.name)) > 0])
    error_message = <<-EOT
      Each secret must have a non-empty `name`.
      See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-secrets.html

      Example:
        { name = "DB_USER", valueFrom = "arn:aws:secretsmanager:us-west-2:990878119577:secret:my-secret-AbCdEf" }
    EOT
  }

  validation {
    condition     = alltrue([for s in var.secrets : can(regex("^arn:aws[^:]*:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:.+", s.valueFrom))])
    error_message = <<-EOT
      Each secret `valueFrom` must be a valid Secrets Manager ARN.
      See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-secrets.html#secrets-iam

      Whole secret (value injected as raw string):
        { name = "DB_CREDENTIALS", valueFrom = "arn:aws:secretsmanager:us-west-2:990878119577:secret:my-secret-AbCdEf" }

      Single JSON key (only the extracted value is injected):
        { name = "DB_USER", valueFrom = "arn:aws:secretsmanager:us-west-2:990878119577:secret:my-secret-AbCdEf:DB_USER::" }
    EOT
  }
}
