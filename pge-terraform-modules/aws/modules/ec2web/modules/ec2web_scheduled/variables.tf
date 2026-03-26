variable "asg_name" {
  description = "The name of the Auto Scaling Group"
  type        = string
}

variable "time_zone" {
  description = "The timezone for the Auto Scaling Schedule"
  type        = string
  default     = "US/Pacific"
}

variable "schedules" {
  description = "List of schedules with start and stop times"
  type = list(object({
    name = string
    weekday_time_windows = list(object({
      min_size         = number
      max_size         = number
      desired_capacity = number
      start_time       = string
      stop_time        = string
    }))
    weekend_time_windows = list(object({
      min_size         = number
      max_size         = number
      desired_capacity = number
      start_time       = string
      stop_time        = string
    }))
    default_vals = object({
      min_size         = number
      max_size         = number
      desired_capacity = number
    })
  }))
  default = [{ // no schedules given
    name                 = "default-schedule"
    weekday_time_windows = []
    weekend_time_windows = []
    default_vals = {
      min_size         = 1
      max_size         = 1
      desired_capacity = null
    }
  }]
}