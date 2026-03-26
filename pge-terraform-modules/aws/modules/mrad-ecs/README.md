<!-- BEGIN_TF_DOCS -->
# PG&E Mrad ECS Module
 MRAD specific composite Terraform ECS module to provision SAF compliant resources

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_aws.ccoe_dns"></a> [aws.ccoe\_dns](#provider\_aws.ccoe\_dns) | ~> 5.0 |
| <a name="provider_aws.r53"></a> [aws.r53](#provider\_aws.r53) | ~> 5.0 |

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
| <a name="module_alb_cert"></a> [alb\_cert](#module\_alb\_cert) | app.terraform.io/pgetech/acm/aws | 0.0.7 |
| <a name="module_app_container"></a> [app\_container](#module\_app\_container) | app.terraform.io/pgetech/ecs/aws//modules/ecs_container_definition | 0.0.40 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | app.terraform.io/pgetech/ecr/aws | 0.0.7 |
| <a name="module_ecs_execution_role"></a> [ecs\_execution\_role](#module\_ecs\_execution\_role) | app.terraform.io/pgetech/iam/aws | 0.0.10 |
| <a name="module_ecs_fargate"></a> [ecs\_fargate](#module\_ecs\_fargate) | app.terraform.io/pgetech/ecs/aws//modules/ecs_fargate | 0.0.40 |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | app.terraform.io/pgetech/ecs/aws//modules/ecs_service | 0.1.4 |
| <a name="module_ecs_task_definition"></a> [ecs\_task\_definition](#module\_ecs\_task\_definition) | app.terraform.io/pgetech/ecs/aws//modules/ecs_task_definition | 0.0.40 |
| <a name="module_ecs_task_role"></a> [ecs\_task\_role](#module\_ecs\_task\_role) | app.terraform.io/pgetech/iam/aws | 0.0.10 |
| <a name="module_lb_access_logs_s3_bucket"></a> [lb\_access\_logs\_s3\_bucket](#module\_lb\_access\_logs\_s3\_bucket) | app.terraform.io/pgetech/s3/aws | 0.0.14 |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | app.terraform.io/pgetech/alb/aws | 0.0.9 |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.0.9 |
| <a name="module_sumo_logger"></a> [sumo\_logger](#module\_sumo\_logger) | app.terraform.io/pgetech/mrad-sumo/aws | 3.0.9-rc1 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ecs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_route53_record.service_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.ecs_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.private_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_s3_bucket.logging_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_subnet.ecs_private1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.ecs_private2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.ecs_private3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.private3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.mrad_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | Any additional security groups to be added to ECS. | `list(string)` | `[]` | no |
| <a name="input_additional_task_iam_policy"></a> [additional\_task\_iam\_policy](#input\_additional\_task\_iam\_policy) | An optional additional IAM policy to attach to the task role | `string` | `null` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum number of tasks for autoscaling | `number` | `3` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum number of tasks for autoscaling | `number` | `1` | no |
| <a name="input_autoscaling_scale_in_cooldown"></a> [autoscaling\_scale\_in\_cooldown](#input\_autoscaling\_scale\_in\_cooldown) | Time (in seconds) to wait before allowing scale-in operations | `number` | `60` | no |
| <a name="input_autoscaling_scale_out_cooldown"></a> [autoscaling\_scale\_out\_cooldown](#input\_autoscaling\_scale\_out\_cooldown) | Time (in seconds) to wait before allowing scale-out operations | `number` | `60` | no |
| <a name="input_autoscaling_target_cpu"></a> [autoscaling\_target\_cpu](#input\_autoscaling\_target\_cpu) | Target CPU utilization percentage for autoscaling | `number` | `70` | no |
| <a name="input_availability_zone_rebalancing"></a> [availability\_zone\_rebalancing](#input\_availability\_zone\_rebalancing) | Automatically redistributes tasks within a service across Availability Zones. Valid values: ENABLED, DISABLED. Default: DISABLED. | `string` | `"DISABLED"` | no |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | The name of the AWS account or environment. Should be one of: `Dev`, `Test`, `QA`, `Prod` | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to use for storing logs. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | The AWS role used for the Sumo logger module. | `string` | n/a | yes |
| <a name="input_balancer_port"></a> [balancer\_port](#input\_balancer\_port) | The port on which the load balancer listens. | `string` | `443` | no |
| <a name="input_branch"></a> [branch](#input\_branch) | The name of the git branch this CodePipeline is configured to build. Usually you should set this to `var.TFC_CONFIGURATION_VERSION_GIT_BRANCH`. See: https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment | `string` | n/a | yes |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | The maximum percentage of running instances this ECS service allows during a deployment (i.e. surge deployment). | `number` | `"200"` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | The minimum percentage of running instances this ECS service requires to be healthy during a deployment. | `number` | `"100"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of ECS tasks to run | `number` | `1` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The base domain name to be used for ALB and ACM. For non-prod environments (not QA or Prod) you should generally set this to `nonprod.pge.com`. | `string` | `"dc.pge.com"` | no |
| <a name="input_ecs_subnet1"></a> [ecs\_subnet1](#input\_ecs\_subnet1) | The name of the first subnet to use for the ECS service. | `string` | `""` | no |
| <a name="input_ecs_subnet2"></a> [ecs\_subnet2](#input\_ecs\_subnet2) | The name of the second subnet to use for the ECS service. | `string` | `""` | no |
| <a name="input_ecs_subnet3"></a> [ecs\_subnet3](#input\_ecs\_subnet3) | The name of the third subnet to use for the ECS service. | `string` | `""` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Whether to enable autoscaling for ECS services | `bool` | `false` | no |
| <a name="input_entry_point"></a> [entry\_point](#input\_entry\_point) | The entry point for the container. | `list(string)` | <pre>[<br/>  "bash",<br/>  "run.sh"<br/>]</pre> | no |
| <a name="input_filter_pattern"></a> [filter\_pattern](#input\_filter\_pattern) | The CloudWatch Logs filter pattern for pattern matching logs to send to Sumo Logic. Applies to an `aws_cloudwatch_log_subscription_filter`. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter#filter_pattern | `string` | `""` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Path for the HTTP health check used to determine if the container is healthy. | `string` | `"/."` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Amount of time, in seconds, during which no response from a target means a failed health check, from 2 to 120 seconds. | `number` | `5` | no |
| <a name="input_healthcheck_enabled"></a> [healthcheck\_enabled](#input\_healthcheck\_enabled) | If false, disables the ECS task health check for the container. | `bool` | `true` | no |
| <a name="input_lb"></a> [lb](#input\_lb) | If true, provision a AWS ALB for this ECS instance. | `bool` | `false` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | The document for the ECR lifecycle policy. | `string` | `"{\n    \"rules\": [\n        {\n            \"rulePriority\": 1,\n            \"description\": \"Keep last 3 tagged images\",\n            \"selection\": {\n                \"tagStatus\": \"any\",\n                \"countType\": \"imageCountMoreThan\",\n                \"countNumber\": 3\n            },\n            \"action\": {\n                \"type\": \"expire\"\n            }\n        }\n    ]\n}\n"` | no |
| <a name="input_partner"></a> [partner](#input\_partner) | The name of the partner team that owns this pipeline. | `string` | `"MRAD"` | no |
| <a name="input_port"></a> [port](#input\_port) | The port on which the application code is listening for HTTP requests. | `number` | `8080` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project. | `string` | n/a | yes |
| <a name="input_subnet1"></a> [subnet1](#input\_subnet1) | The name of the first subnet to use for the ALB. | `string` | `""` | no |
| <a name="input_subnet2"></a> [subnet2](#input\_subnet2) | The name of the second subnet to use for the ALB. | `string` | `""` | no |
| <a name="input_subnet3"></a> [subnet3](#input\_subnet3) | The name of the third subnet to use for the ALB. | `string` | `""` | no |
| <a name="input_subnet_qualifier"></a> [subnet\_qualifier](#input\_subnet\_qualifier) | If `partner != MRAD`, this is used to select a subnet by environment. | `map(any)` | <pre>{<br/>  "Dev": "Dev-2",<br/>  "Prod": "Prod-2",<br/>  "QA": "QA-2",<br/>  "Test": "Test-2"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to these resources which indicates their provenance. | `map(string)` | `{}` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | CPU configuration for this ECS task. 1024 = 1 vCPU. See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `number` | `512` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Memory configuration for this ECS task. 1024 = 1024 MiB. See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | `number` | `1024` | no |
| <a name="input_task_names"></a> [task\_names](#input\_task\_names) | If more than one task, associated service and ecr repo is need then use a list of names to create multiple. It gets converted to a Set, e.g. ["Asset360", "Public", "Cache"]. | `list(any)` | <pre>[<br/>  "ECS"<br/>]</pre> | no |
| <a name="input_ulimit_nofile_hard"></a> [ulimit\_nofile\_hard](#input\_ulimit\_nofile\_hard) | The `ulimit` hard limit for the number of file descriptors. See: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_Ulimit.html | `number` | `"4096"` | no |
| <a name="input_ulimit_nofile_soft"></a> [ulimit\_nofile\_soft](#input\_ulimit\_nofile\_soft) | The `ulimit` soft limit for the number of file descriptors. See: https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_Ulimit.html | `number` | `"1024"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | If `partner` is not MRAD, the name of the VPC to use for each CodeBuild step. | `string` | `""` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_enabled"></a> [autoscaling\_enabled](#output\_autoscaling\_enabled) | Whether autoscaling is enabled |
| <a name="output_autoscaling_policy_arns"></a> [autoscaling\_policy\_arns](#output\_autoscaling\_policy\_arns) | ARNs of the autoscaling policies |
| <a name="output_autoscaling_target_ids"></a> [autoscaling\_target\_ids](#output\_autoscaling\_target\_ids) | IDs of the autoscaling targets |
| <a name="output_ecr_repo_urls"></a> [ecr\_repo\_urls](#output\_ecr\_repo\_urls) | n/a |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | n/a |
| <a name="output_ecs_task_definition_family_map"></a> [ecs\_task\_definition\_family\_map](#output\_ecs\_task\_definition\_family\_map) | n/a |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | The ARN of the load balancer. |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_lb_zone_id"></a> [lb\_zone\_id](#output\_lb\_zone\_id) | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |
| <a name="output_listener_https_arn"></a> [listener\_https\_arn](#output\_listener\_https\_arn) | ARN of the listener |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |

<!-- END_TF_DOCS -->
