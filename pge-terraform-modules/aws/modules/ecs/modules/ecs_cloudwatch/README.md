<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
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
| [aws_cloudwatch_dashboard.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | `"us-west-2"` | no |
| <a name="input_dashboard_name"></a> [dashboard\_name](#input\_dashboard\_name) | New dashboard name | `string` | `"infrastracture-metrics"` | no |
| <a name="input_services"></a> [services](#input\_services) | Services list that would be used to build wdgets inside dashboard | <pre>list(object({<br>    cluster_name  = string<br>    service_name  = string<br>    widget_prefix = string<br>    lb_arn_suffix = string<br>  }))</pre> | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard_arn"></a> [dashboard\_arn](#output\_dashboard\_arn) | ECS Dashboard arn |

<!-- END_TF_DOCS -->