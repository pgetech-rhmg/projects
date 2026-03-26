<!-- BEGIN_TF_DOCS -->
# AWS EBS-multi attach enabled module example

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
| <a name="module_ebs"></a> [ebs](#module\_ebs) | ../../ | n/a |
| <a name="module_ec2_01"></a> [ec2\_01](#module\_ec2\_01) | app.terraform.io/pgetech/ec2/aws | 0.1.1 |
| <a name="module_ec2_02"></a> [ec2\_02](#module\_ec2\_02) | app.terraform.io/pgetech/ec2/aws | 0.1.1 |
| <a name="module_ec2_security_group"></a> [ec2\_security\_group](#module\_ec2\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.golden_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Optional_tags"></a> [Optional\_tags](#input\_Optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_ebs_availability_zone"></a> [ebs\_availability\_zone](#input\_ebs\_availability\_zone) | The names of the availability zone | `string` | n/a | yes |
| <a name="input_ebs_device_name"></a> [ebs\_device\_name](#input\_ebs\_device\_name) | The device name to expose to the instance. | `string` | n/a | yes |
| <a name="input_ebs_iops"></a> [ebs\_iops](#input\_ebs\_iops) | The amount of IOPS to provision for the disk. Only valid for type of io1, io2 or gp3. | `number` | n/a | yes |
| <a name="input_ebs_multi_attach_enabled"></a> [ebs\_multi\_attach\_enabled](#input\_ebs\_multi\_attach\_enabled) | Specifies whether to enable Amazon EBS Multi-Attach. Multi-Attach is supported exclusively on io1 volumes. | `bool` | n/a | yes |
| <a name="input_ebs_size"></a> [ebs\_size](#input\_ebs\_size) | The size of the drive in GiBs | `string` | n/a | yes |
| <a name="input_ebs_type"></a> [ebs\_type](#input\_ebs\_type) | The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1. | `string` | n/a | yes |
| <a name="input_ec2_01_name"></a> [ec2\_01\_name](#input\_ec2\_01\_name) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_ec2_02_name"></a> [ec2\_02\_name](#input\_ec2\_02\_name) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_ec2_az"></a> [ec2\_az](#input\_ec2\_az) | List of availability zone for ec2 | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | type of the ec2 instance | `string` | n/a | yes |
| <a name="input_golden_ami_name"></a> [golden\_ami\_name](#input\_golden\_ami\_name) | The name given in the parameter store for the golden ami | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name for kms | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | Security group for example usage with EBS | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_subnet_id1_name"></a> [subnet\_id1\_name](#input\_subnet\_id1\_name) | The name given in the parameter store for the subnet id 1 | `string` | n/a | yes |
| <a name="input_vpc_id_name"></a> [vpc\_id\_name](#input\_vpc\_id\_name) | The name given in the parameter store for the vpc id | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_01_arn"></a> [ec2\_01\_arn](#output\_ec2\_01\_arn) | The ARN of the instance |
| <a name="output_ec2_01_capacity_reservation_specification"></a> [ec2\_01\_capacity\_reservation\_specification](#output\_ec2\_01\_capacity\_reservation\_specification) | Capacity reservation specification of the instance |
| <a name="output_ec2_01_id"></a> [ec2\_01\_id](#output\_ec2\_01\_id) | The ID of the instance |
| <a name="output_ec2_01_instance_state"></a> [ec2\_01\_instance\_state](#output\_ec2\_01\_instance\_state) | The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped` |
| <a name="output_ec2_01_primary_network_interface_id"></a> [ec2\_01\_primary\_network\_interface\_id](#output\_ec2\_01\_primary\_network\_interface\_id) | The ID of the instance's primary network interface |
| <a name="output_ec2_01_private_dns"></a> [ec2\_01\_private\_dns](#output\_ec2\_01\_private\_dns) | The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| <a name="output_ec2_01_tags_all"></a> [ec2\_01\_tags\_all](#output\_ec2\_01\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |
| <a name="output_ec2_02_arn"></a> [ec2\_02\_arn](#output\_ec2\_02\_arn) | The ARN of the instance |
| <a name="output_ec2_02_capacity_reservation_specification"></a> [ec2\_02\_capacity\_reservation\_specification](#output\_ec2\_02\_capacity\_reservation\_specification) | Capacity reservation specification of the instance |
| <a name="output_ec2_02_id"></a> [ec2\_02\_id](#output\_ec2\_02\_id) | The ID of the instance |
| <a name="output_ec2_02_instance_state"></a> [ec2\_02\_instance\_state](#output\_ec2\_02\_instance\_state) | The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped` |
| <a name="output_ec2_02_primary_network_interface_id"></a> [ec2\_02\_primary\_network\_interface\_id](#output\_ec2\_02\_primary\_network\_interface\_id) | The ID of the instance's primary network interface |
| <a name="output_ec2_02_private_dns"></a> [ec2\_02\_private\_dns](#output\_ec2\_02\_private\_dns) | The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| <a name="output_ec2_02_tags_all"></a> [ec2\_02\_tags\_all](#output\_ec2\_02\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |
| <a name="output_volume_arn"></a> [volume\_arn](#output\_volume\_arn) | The ARN of EBS |
| <a name="output_volume_id"></a> [volume\_id](#output\_volume\_id) | The ID of EBS |
| <a name="output_volume_tags_all"></a> [volume\_tags\_all](#output\_volume\_tags\_all) | A map of tags assigned to the resource |

<!-- END_TF_DOCS -->