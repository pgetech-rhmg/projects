<!-- BEGIN_TF_DOCS -->
# AWS EC2Web Scheduler Submodule

Terraform submodule which creates SAF2.0 EC2Web scheduled resource in AWS

This module allows you to create schedules for an AWS Auto Scaling Group (ASG). You can define schedules for weekdays, weekends, and a default configuration

**Important**: Start and stop times must be in 24HR format, and across different schedules should not overlap as this will cause Terraform to create duplicate schedules and lead to errors.

ASG must already exist to use this submodule to add schedules

```
# invoke the module
module "scheduler" {
 source   = "../../modules/ec2web_scheduled"
 asg_name = module.ec2web_test.asg_name # Must be taken from existing ASG
 schedules = var.schedules
}
```

Example schedules in terraform.auto.tfvars:
```
 schedules = [
  {
    name = "test-schedule"
    # Start and Stop times must be in 24HR format (0:00-23:59)
    weekday_time_windows = [
      {
        min_size         = 5
        max_size         = 10
        desired_capacity = 5
        start_time       = "12:00"
        stop_time        = "14:00"
      },
      {
        min_size         = 3
        max_size         = 7
        desired_capacity = 3
        start_time       = "14:01" # 14:00 would result in error with above schedule as start and previous stop time coincide
        stop_time        = "15:30"
      }
    ]
    # Can leave time window empty if no schedule specified []
    weekend_time_windows = [
      {
        min_size         = 2
        max_size         = 4
        desired_capacity = 2
        start_time       = "00:00"
        stop_time        = "23:59" # example of full weekend
      }
    ]
    default_vals = {
      min_size         = 1
      max_size         = 2
      desired_capacity = 1
    }
  }
]
```

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_schedule.schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | The name of the Auto Scaling Group | `string` | n/a | yes |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | List of schedules with start and stop times | <pre>list(object({<br>    name = string<br>    weekday_time_windows = list(object({<br>      min_size         = number<br>      max_size         = number<br>      desired_capacity = number<br>      start_time       = string<br>      stop_time        = string<br>    }))<br>    weekend_time_windows = list(object({<br>      min_size         = number<br>      max_size         = number<br>      desired_capacity = number<br>      start_time       = string<br>      stop_time        = string<br>    }))<br>    default_vals = object({<br>      min_size         = number<br>      max_size         = number<br>      desired_capacity = number<br>    })<br>  }))</pre> | <pre>[<br>  {<br>    "default_vals": {<br>      "desired_capacity": null,<br>      "max_size": 1,<br>      "min_size": 1<br>    },<br>    "name": "default-schedule",<br>    "weekday_time_windows": [],<br>    "weekend_time_windows": []<br>  }<br>]</pre> | no |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | The timezone for the Auto Scaling Schedule | `string` | `"US/Pacific"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_schedules"></a> [schedules](#output\_schedules) | Auto Scaling Group scehdule configurations |


<!-- END_TF_DOCS -->