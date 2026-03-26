variable "tags" {
  description = "A map of tags to add to CW rules"
  type        = map(string)
  default     = {}
}

variable "name" {
  type        = string
  description = "The name of the service that this Rule is associated with"
}

variable "branch" {
  description = "Indicates the branch being deployed, used to namespace resource names to prevent conflicts"
  type        = string
}

variable "schedule" {
  type        = string
  description = "The schedule expression for the CloudWatch Rule"
  default     = null
}

variable "description" {
  type        = string
  description = "The description for the CloudWatch Rule"
}

variable "input" {
  type        = string
  description = "The input you're sending through the CloudWatch Rule"
}

variable "arn" {
  type        = string
  description = "The ARN of the resource you're triggering through the CloudWatch Rule"
}

variable "aws_account" {
  type        = string
  description = "Aws account name, Dev, QA, Prod"
}

variable "enabled" {
  type        = bool
  description = "If the CloudWatch Rule is enabled or not"
  default     = true
}

variable "ecs" {
  type        = bool
  description = "Is this targeting an ECS Task or not"
  default     = false
}

variable "ecs_security_group_id" {
  type        = string
  description = "security group ID from the ECS module"
  default     = "none"
}

variable "additional_security_groups" {
  type        = list(string)
  description = "Any additional security groups to be added to ECS"
  default     = []
}

variable "subnet_qualifier" {
  type        = map(any)
  description = "The subnet qualifier"
  default     = { Dev = "Dev-2", Test = "Test-2", QA = "QA", Prod = "Prod" }
}

variable "subnet1" {
  type        = string
  description = "subnet1 name"
  default     = ""
}

variable "subnet2" {
  type        = string
  description = "subnet2 name"
  default     = ""
}

variable "subnet3" {
  type        = string
  description = "subnet3 name"
  default     = ""
}

variable "partner" {
  type        = string
  description = "partner team name"
  default     = "MRAD"
}

variable "task_definition_arn" {
  type        = string
  description = "task definition arn that should targeted"
  default     = null
}


