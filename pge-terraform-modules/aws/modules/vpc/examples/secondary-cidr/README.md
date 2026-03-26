<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.1 |

## Providers

No providers.

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
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_vpc-sec-cidr"></a> [vpc-sec-cidr](#module\_vpc-sec-cidr) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | AWS Account Number where the resources will be created | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | The name of the role to assume in the target account. | `string` | `"CloudAdmin"` | no |
| <a name="input_create_vpc_sec_cidr"></a> [create\_vpc\_sec\_cidr](#input\_create\_vpc\_sec\_cidr) | create secondary cidr integration with vpc if true | `bool` | `false` | no |
| <a name="input_parameter_sec_vpc_cidr"></a> [parameter\_sec\_vpc\_cidr](#input\_parameter\_sec\_vpc\_cidr) | secondary IP cidr assigned to the VPC | `string` | `"100.64.0.0/16"` | no |
| <a name="input_parameter_subnet_ida"></a> [parameter\_subnet\_ida](#input\_parameter\_subnet\_ida) | SSM parameter name to store subnet id a of secondary cidr | `string` | `null` | no |
| <a name="input_parameter_subnet_idb"></a> [parameter\_subnet\_idb](#input\_parameter\_subnet\_idb) | SSM parameter name to store subnet id b of secondary cidr | `string` | `null` | no |
| <a name="input_parameter_subnet_idc"></a> [parameter\_subnet\_idc](#input\_parameter\_subnet\_idc) | SSM parameter name to store subnet id c of secondary cidr | `string` | `null` | no |
| <a name="input_parameter_transit_gateway"></a> [parameter\_transit\_gateway](#input\_parameter\_transit\_gateway) | Id of the transit gate-way | `string` | `null` | no |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | SSM Parameter name where the VPC ID is stored | `string` | `null` | no |
| <a name="input_subnet_a_cidr"></a> [subnet\_a\_cidr](#input\_subnet\_a\_cidr) | The IPv4 CIDR block assigned to the subnet\_a | `string` | `null` | no |
| <a name="input_subnet_a_name"></a> [subnet\_a\_name](#input\_subnet\_a\_name) | The name tag to assign to subnet A | `string` | `"subnet-azA"` | no |
| <a name="input_subnet_b_cidr"></a> [subnet\_b\_cidr](#input\_subnet\_b\_cidr) | The IPv4 CIDR block assigned to the subnet\_b | `string` | `null` | no |
| <a name="input_subnet_b_name"></a> [subnet\_b\_name](#input\_subnet\_b\_name) | The name tag to assign to subnet B | `string` | `"subnet-azB"` | no |
| <a name="input_subnet_c_cidr"></a> [subnet\_c\_cidr](#input\_subnet\_c\_cidr) | The IPv4 CIDR block assigned to the subnet\_c | `string` | `null` | no |
| <a name="input_subnet_c_name"></a> [subnet\_c\_name](#input\_subnet\_c\_name) | The name tag to assign to subnet C | `string` | `"subnet-azC"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_a_id"></a> [subnet\_a\_id](#output\_subnet\_a\_id) | The IDs of the Subnet A resources. |
| <a name="output_subnet_b_id"></a> [subnet\_b\_id](#output\_subnet\_b\_id) | The IDs of the Subnet B resources. |
| <a name="output_subnet_c_id"></a> [subnet\_c\_id](#output\_subnet\_c\_id) | The IDs of the Subnet C resources. |

<!-- END_TF_DOCS -->