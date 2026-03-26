<!-- BEGIN_TF_DOCS -->
# AWS Elastic Beanstalk environment module.
Terraform module which creates SAF2.0 aws\_elastic\_beanstalk\_environment in AWS.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_elastic_beanstalk_environment.environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_environment) | resource |
| [aws_secretsmanager_secret.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.db_password_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_settings"></a> [alb\_settings](#input\_alb\_settings) | {<br>  alb\_certificate\_arn      : ARN of the default SSL server certificate.<br>  elb\_logs\_s3\_bucket\_name  : S3 bucket name to store alb logs.<br>  elb\_subnets              : The IDs of the subnet or subnets for the elastic load balancer. If you have multiple subnets, specify the value as a single comma-separated string of subnet IDs.<br>} | <pre>object({<br>    alb_certificate_arn     = string<br>    elb_logs_s3_bucket_name = string<br>    elb_subnets             = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application that contains the version to be deployed | `string` | n/a | yes |
| <a name="input_asg_settings"></a> [asg\_settings](#input\_asg\_settings) | {<br>  vpcid              : The ID of the VPC.<br>  asg\_subnets        : The IDs of the Auto Scaling group subnet or subnets. If you have multiple subnets, specify the value as a single comma-separated string of subnet IDs.<br>} | <pre>object({<br>    vpcid       = string<br>    asg_subnets = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_cname_prefix"></a> [cname\_prefix](#input\_cname\_prefix) | Prefix to use for the fully qualified DNS name of the Environment. | `string` | `null` | no |
| <a name="input_db_settings"></a> [db\_settings](#input\_db\_settings) | {<br>  engine                                      : The name of the database engine to use for this instance.<br>  version                                     : The version number of the database engine.<br>  vpc\_subnets                                 : The IDs for your Amazon VPC.<br>  rds                                         : Specifies whether a DB instance is coupled to your environment. If toggled to true, Elastic Beanstalk creates a new DB instance coupled to your environment. If toggled to false, Elastic Beanstalk initiates decoupling of the DB instance from your environment.<br>  secretsmanager\_db\_password\_secret\_name      : Enter the name of secrets manager for db\_password.<br>} | <pre>object({<br>    engine                                 = string<br>    version                                = string<br>    vpc_subnets                            = list(string)<br>    rds                                    = bool<br>    secretsmanager_db_password_secret_name = string<br>  })</pre> | <pre>{<br>  "engine": "mysql",<br>  "rds": false,<br>  "secretsmanager_db_password_secret_name": null,<br>  "version": "8.0.36",<br>  "vpc_subnets": null<br>}</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | Short description of the Environment | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | A unique name for this | `string` | n/a | yes |
| <a name="input_platform_arn"></a> [platform\_arn](#input\_platform\_arn) | The ARN of the Elastic Beanstalk Platform to use in deployment. | `string` | `null` | no |
| <a name="input_poll_interval"></a> [poll\_interval](#input\_poll\_interval) | The time between polling the AWS API to check if changes have been applied. | `number` | `null` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Option settings to configure the new Environment. These override specific values that are set as defaults. | <pre>list(object({<br>    namespace = string<br>    name      = string<br>    value     = string<br>    resource  = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_solution_stack_name"></a> [solution\_stack\_name](#input\_solution\_stack\_name) | A solution stack to base your environment. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A set of tags to apply to the Environment. If configured with a provider | `map(string)` | n/a | yes |
| <a name="input_template_name"></a> [template\_name](#input\_template\_name) | The name of the Elastic Beanstalk Configuration template to use in deployment. | `string` | `null` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Elastic Beanstalk Environment tier. Valid values are Worker or WebServer. If tier is left blank WebServer will be used. | `string` | `null` | no |
| <a name="input_version_label"></a> [version\_label](#input\_version\_label) | The name of the Elastic Beanstalk Application Version to use in deployment. | `string` | `null` | no |
| <a name="input_wait_for_ready_timeout"></a> [wait\_for\_ready\_timeout](#input\_wait\_for\_ready\_timeout) | The maximum duration that Terraform should wait for an Elastic Beanstalk Environment to be in a ready state before timing out. | `string` | `"20m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_settings"></a> [all\_settings](#output\_all\_settings) | List of all option settings configured in this Environment. |
| <a name="output_application"></a> [application](#output\_application) | The Elastic Beanstalk Application specified for this environment. |
| <a name="output_autoscaling_groups"></a> [autoscaling\_groups](#output\_autoscaling\_groups) | The autoscaling groups used by this Environment. |
| <a name="output_aws_elastic_beanstalk_environment_all"></a> [aws\_elastic\_beanstalk\_environment\_all](#output\_aws\_elastic\_beanstalk\_environment\_all) | Map of all aws\_elastic\_beanstalk\_environment attributes |
| <a name="output_cname"></a> [cname](#output\_cname) | Fully qualified DNS name for this Environment. |
| <a name="output_description"></a> [description](#output\_description) | Description of the Elastic Beanstalk Environment. |
| <a name="output_endpoint_url"></a> [endpoint\_url](#output\_endpoint\_url) | The URL to the Load Balancer for this Environment |
| <a name="output_id"></a> [id](#output\_id) | ID of the Elastic Beanstalk Environment. |
| <a name="output_instances"></a> [instances](#output\_instances) | Instances used by this Environment. |
| <a name="output_launch_configurations"></a> [launch\_configurations](#output\_launch\_configurations) | Launch configurations in use by this Environment. |
| <a name="output_load_balancers"></a> [load\_balancers](#output\_load\_balancers) | Elastic load balancers in use by this Environment. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Elastic Beanstalk Environment. |
| <a name="output_queues"></a> [queues](#output\_queues) | SQS queues in use by this Environment. |
| <a name="output_setting"></a> [setting](#output\_setting) | Settings specifically set for this Environment. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider |
| <a name="output_tier"></a> [tier](#output\_tier) | The environment tier specified. |
| <a name="output_triggers"></a> [triggers](#output\_triggers) | Autoscaling triggers in use by this Environment. |


<!-- END_TF_DOCS -->