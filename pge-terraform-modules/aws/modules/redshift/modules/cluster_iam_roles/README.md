<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0 |

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
| [aws_redshift_cluster_iam_roles.cluster_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_cluster_iam_roles) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The name of the Redshift Cluster to attach IAM Roles. | `string` | n/a | yes |
| <a name="input_iam_role_arns"></a> [iam\_role\_arns](#input\_iam\_role\_arns) | A list of IAM Role ARNs to associate with the cluster. A Maximum of 10 can be associated to the cluster at any time. | `list(string)` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_redshift_cluster_iam_roles_all"></a> [aws\_redshift\_cluster\_iam\_roles\_all](#output\_aws\_redshift\_cluster\_iam\_roles\_all) | A map of aws redshift cluster iam roles attributes references |
| <a name="output_id"></a> [id](#output\_id) | The Redshift Cluster ID. |

<!-- END_TF_DOCS -->