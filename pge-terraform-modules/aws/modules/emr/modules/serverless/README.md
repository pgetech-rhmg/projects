# AWS EMR Serverless module

Terraform module which creates AWS EMR Serverless resources.

Source can be found at https://github.com/pgetech/pge-terraform-modules

<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_emrserverless_application.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emrserverless_application) | resource |
| [aws_emr_release_labels.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/emr_release_labels) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture"></a> [architecture](#input\_architecture) | The CPU architecture type, e.g., X86\_64 or ARM64. | `string` | `"X86_64"` | no |
| <a name="input_auto_start_configuration"></a> [auto\_start\_configuration](#input\_auto\_start\_configuration) | Configuration for auto-starting the application | <pre>object({<br/>    enabled = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_auto_stop_configuration"></a> [auto\_stop\_configuration](#input\_auto\_stop\_configuration) | Configuration for auto-stopping the application | <pre>object({<br/>    enabled = optional(bool)<br/>    idle_timeout_minutes = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_image_configuration"></a> [image\_configuration](#input\_image\_configuration) | custom image configuration block. | <pre>object({<br/>      image_uri = optional(string)<br/>    })</pre> | `null` | no |
| <a name="input_initial_capacity"></a> [initial\_capacity](#input\_initial\_capacity) | Initial capacity configuration for EMR Serverless | <pre>map(object({<br/>    initial_capacity_type = string<br/>    initial_capacity_config = optional(object({<br/>      worker_count = number<br/>      worker_configuration = optional(object({<br/>        cpu    = string<br/>        memory = string<br/>        disk   = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_interactive_configuration"></a> [interactive\_configuration](#input\_interactive\_configuration) | Configuration for interactive workloads in EMR Serverless, including Livy and Studio endpoints. | <pre>object({<br/>    livy_endpoint_enabled = optional(bool)<br/>    studio_enabled        = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_maximum_capacity"></a> [maximum\_capacity](#input\_maximum\_capacity) | Map of maximum capacity configurations for EMR Serverless applications | <pre>object({<br/>    cpu    = string<br/>    memory = string<br/>    disk   = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the EMR Serverless application | `string` | n/a | yes |
| <a name="input_monitoring_configuration"></a> [monitoring\_configuration](#input\_monitoring\_configuration) | The monitoring configuration for the application, prometheus_monitoring_configuration - Only supported in EMR 7.1.0 and later versions.| <pre>object({<br/>    cloudwatch_logging_configuration = optional(object({<br/>      enabled                = optional(bool)<br/>      log_group_name         = optional(string)<br/>      log_stream_name_prefix = optional(string)<br/>      encryption_key_arn     = optional(string)<br/>      log_types = optional(list(object({<br/>        name   = string<br/>        values = list(string)<br/>      })))<br/>    }))<br/>    managed_persistence_monitoring_configuration = optional(object({<br/>      enabled            = optional(bool)<br/>      encryption_key_arn = optional(string)<br/>    }))<br/>    prometheus_monitoring_configuration = optional(object({<br/>      remote_write_url = optional(string)<br/>    }))<br/>    s3_monitoring_configuration = optional(object({<br/>      log_uri            = optional(string)<br/>      encryption_key_arn = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | network configuration for EMR serverless. | <pre>object({<br/>      subnet_ids = optional(list(string))<br/>      security_group_ids = optional(list(string))<br/>    })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where this resource will be managed. Defaults to the region set in the provider configuration. | `string` | `null` | no |
| <a name="input_release_label"></a> [release\_label](#input\_release\_label) | The EMR release label, e.g., emr-6.6.0 | `string` | `null` | no |
| <a name="input_release_label_prefix"></a> [release\_label\_prefix](#input\_release\_label\_prefix) | Release label prefix used to lookup a release label | `string` | `"emr-6"` | no |
| <a name="input_scheduler_configuration"></a> [scheduler\_configuration](#input\_scheduler\_configuration) | Scheduler configuration for batch and streaming jobs running on this application. Supported with release labels emr-7.0.0 and above. | <pre>object({<br/>    max_concurrent_runs   = optional(number)<br/>    queue_timeout_minutes = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | The type of application, e.g., SPARK or HIVE. | `string` | `"SPARK"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_emr_serverless_arn"></a> [emr\_serverless\_arn](#output\_emr\_serverless\_arn) | Amazon Resource Name (ARN) of the application |
| <a name="output_emr_serverless_id"></a> [emr\_serverless\_id](#output\_emr\_serverless\_id) | ID of the application |

<!-- END_TF_DOCS -->
