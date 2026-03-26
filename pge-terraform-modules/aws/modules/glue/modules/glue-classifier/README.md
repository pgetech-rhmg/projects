<!-- BEGIN_TF_DOCS -->
# AWS Glue Classifier module.
Terraform module which creates SAF2.0 Glue Classifier in AWS.
It is only valid to create one type of classifier (csv, grok, JSON, or XML). Changing classifier types will recreate the classifier.

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
| [aws_glue_classifier.glue_classifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_classifier) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_classifier_name"></a> [classifier\_name](#input\_classifier\_name) | The name of the classifier. | `string` | n/a | yes |
| <a name="input_csv_classifier"></a> [csv\_classifier](#input\_csv\_classifier) | A classifier for CSV content. | `list(any)` | `[]` | no |
| <a name="input_grok_classifier"></a> [grok\_classifier](#input\_grok\_classifier) | A classifier that uses GROK patterns. | `map(string)` | `null` | no |
| <a name="input_json_path"></a> [json\_path](#input\_json\_path) | A JsonPath string defining the JSON data for the classifier to classify. | `string` | `null` | no |
| <a name="input_xml_classifier"></a> [xml\_classifier](#input\_xml\_classifier) | A classifier for XML content. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_classifier"></a> [aws\_glue\_classifier](#output\_aws\_glue\_classifier) | The map of aws\_glue\_classifier object. |
| <a name="output_classifier_id"></a> [classifier\_id](#output\_classifier\_id) | Name of the classifier. |


<!-- END_TF_DOCS -->