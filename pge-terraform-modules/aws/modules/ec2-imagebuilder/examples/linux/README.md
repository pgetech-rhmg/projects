<!-- BEGIN_TF_DOCS -->
# AWS EC2 Image Builder Module
Terraform module which creates and manages AWS EC2 Image Builder resources such as image pipelines, recipes, and infrastructure configurations.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.78.0 |

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
| <a name="module_ec2-image-builder"></a> [ec2-image-builder](#module\_ec2-image-builder) | ../../ | n/a |
| <a name="module_ec2_image_builder_s3_bucket"></a> [ec2\_image\_builder\_s3\_bucket](#module\_ec2\_image\_builder\_s3\_bucket) | app.terraform.io/pgetech/s3/aws | 0.1.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_imagebuilder_component.build_component](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_component) | resource |
| [aws_imagebuilder_component.test_component](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_component) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | Name of AMI | `string` | n/a | yes |
| <a name="input_ami_parameter_store"></a> [ami\_parameter\_store](#input\_ami\_parameter\_store) | Name of parameter store for the golden AMI | `string` | `"/ami/linux/golden"` | no |
| <a name="input_approver_arns"></a> [approver\_arns](#input\_approver\_arns) | A list of AWS authenticated principals who are eligible to either approve or reject the AMI Distribution action. | `list(string)` | <pre>[<br/>  "arn:aws:sts::686137062481:assumed-role/SuperAdmin/SCLF@utility.pge.com",<br/>  "arn:aws:sts::686137062481:assumed-role/SuperAdmin/A2VB@utility.pge.com"<br/>]</pre> | no |
| <a name="input_approver_topic_arn"></a> [approver\_topic\_arn](#input\_approver\_topic\_arn) | ARN of the Image builder approver SNS topic | `string` | `"/ami/base-linux/approver/topic/arn"` | no |
| <a name="input_aws_owned_component_arn"></a> [aws\_owned\_component\_arn](#input\_aws\_owned\_component\_arn) | ARN of AWS provide component | `list(string)` | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the resource need to be created | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_block_device_iops"></a> [block\_device\_iops](#input\_block\_device\_iops) | Provisioned IOPS for the block device (only for io1 or io2 types) | `number` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Imagebuilder logs S3 bucket name | `string` | n/a | yes |
| <a name="input_build_version"></a> [build\_version](#input\_build\_version) | Build Version | `string` | n/a | yes |
| <a name="input_cmk_arn"></a> [cmk\_arn](#input\_cmk\_arn) | Parameter store of the CMK ARN for Lambda environment encryption | `string` | `"/servicekey/lambda"` | no |
| <a name="input_cmk_ebs_arn"></a> [cmk\_ebs\_arn](#input\_cmk\_ebs\_arn) | CMK ARN for EBS image encryption | `string` | `"/servicekey/ebs"` | no |
| <a name="input_delete_on_termination_img_recipe"></a> [delete\_on\_termination\_img\_recipe](#input\_delete\_on\_termination\_img\_recipe) | Delete on Termination of Image Recipe. | `bool` | n/a | yes |
| <a name="input_ec2_imagebuilder_instance_type"></a> [ec2\_imagebuilder\_instance\_type](#input\_ec2\_imagebuilder\_instance\_type) | EC2 Image Builder instance type | `list(string)` | <pre>[<br/>  "m5.large"<br/>]</pre> | no |
| <a name="input_execution_role"></a> [execution\_role](#input\_execution\_role) | ARN of the service linked role for image builder | `string` | `null` | no |
| <a name="input_force_destroy_s3_bucket"></a> [force\_destroy\_s3\_bucket](#input\_force\_destroy\_s3\_bucket) | Whether to destroy the S3 bucket while destroying other resources | `bool` | n/a | yes |
| <a name="input_image_tests_enabled"></a> [image\_tests\_enabled](#input\_image\_tests\_enabled) | Whether to enable the image tests in the image builder image. | `bool` | `true` | no |
| <a name="input_launch_permission_user_ids"></a> [launch\_permission\_user\_ids](#input\_launch\_permission\_user\_ids) | List of AWS account ID's for AMI launch permissions. | `list(string)` | `[]` | no |
| <a name="input_log_policy"></a> [log\_policy](#input\_log\_policy) | Policy for S3 bucket | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the project which will be used as a prefix for every resource. | `string` | `"imagebuilder-linux-example"` | no |
| <a name="input_non_prod_ami_sns_topic_arn"></a> [non\_prod\_ami\_sns\_topic\_arn](#input\_non\_prod\_ami\_sns\_topic\_arn) | Parameter store name for the new AMI NonProd notification topic ARN | `string` | `"/ami/linux/new-ami/nonprod/topic/arn"` | no |
| <a name="input_notification_email"></a> [notification\_email](#input\_notification\_email) | Email address to receive notifications | `list(string)` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags | `map(string)` | `{}` | no |
| <a name="input_parent_image_ssm_path"></a> [parent\_image\_ssm\_path](#input\_parent\_image\_ssm\_path) | Parent Image. | `string` | n/a | yes |
| <a name="input_pipeline_status"></a> [pipeline\_status](#input\_pipeline\_status) | Pipeline status whether to ENABLED OR DISABLED | `string` | n/a | yes |
| <a name="input_platform"></a> [platform](#input\_platform) | Specify the Platform whether Windows, Linux, MacOS | `string` | n/a | yes |
| <a name="input_private_subnet"></a> [private\_subnet](#input\_private\_subnet) | Private Subnets | `string` | `"subnet-0c02015de7dc8232c"` | no |
| <a name="input_receipients"></a> [receipients](#input\_receipients) | Email ID of Receipient | `list(string)` | `[]` | no |
| <a name="input_recipe_description"></a> [recipe\_description](#input\_recipe\_description) | Description of Image Builder Image Recipe | `string` | `"This is the Linux Image Builder Recipe"` | no |
| <a name="input_recipe_version"></a> [recipe\_version](#input\_recipe\_version) | Image Builder Recipe Version. | `string` | `"0.0.1"` | no |
| <a name="input_sender"></a> [sender](#input\_sender) | Email ID of Sender | `string` | n/a | yes |
| <a name="input_ssm_document_name"></a> [ssm\_document\_name](#input\_ssm\_document\_name) | SSM Document Name | `string` | `"release-linux-ami-nonprod"` | no |
| <a name="input_ssm_document_version"></a> [ssm\_document\_version](#input\_ssm\_document\_version) | Version of the resources associated with the SSM Document | `string` | `"1"` | no |
| <a name="input_stack_set_name"></a> [stack\_set\_name](#input\_stack\_set\_name) | Name od StackSet to distribute the golden AMI | `string` | `"current-ami-id-linux-prod"` | no |
| <a name="input_subnet_id_az_a"></a> [subnet\_id\_az\_a](#input\_subnet\_id\_az\_a) | SSM Parameter that holds the subnet for Availability Zone A | `string` | `"/vpc/2/privatesubnet1/id"` | no |
| <a name="input_subnet_id_az_b"></a> [subnet\_id\_az\_b](#input\_subnet\_id\_az\_b) | SSM Parameter that holds the subnet for Availability Zone B | `string` | `"/vpc/2/privatesubnet2/id"` | no |
| <a name="input_subnet_id_az_c"></a> [subnet\_id\_az\_c](#input\_subnet\_id\_az\_c) | SSM Parameter that holds the subnet for Availability Zone C | `string` | `"/vpc/2/privatesubnet3/id"` | no |
| <a name="input_target_accounts_table"></a> [target\_accounts\_table](#input\_target\_accounts\_table) | DynamoDB table of target accounts | `string` | n/a | yes |
| <a name="input_test_version"></a> [test\_version](#input\_test\_version) | Test Version | `string` | `"0.0.1"` | no |
| <a name="input_uninstall_after_build"></a> [uninstall\_after\_build](#input\_uninstall\_after\_build) | Whether to uninstall the system manager agent after the image is built. | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Cidr block for the VPC | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI ID generated by the Imagebuilder Pipeline |
| <a name="output_imagebuilder_creation_log"></a> [imagebuilder\_creation\_log](#output\_imagebuilder\_creation\_log) | Logs of Imagebuilder Image Creation process. |
| <a name="output_imagebuilder_image_arn"></a> [imagebuilder\_image\_arn](#output\_imagebuilder\_image\_arn) | The ARN of the Imagebuilder image |
| <a name="output_imagebuilder_image_name"></a> [imagebuilder\_image\_name](#output\_imagebuilder\_image\_name) | The name of the Imagebuilder name. |
| <a name="output_imagebuilder_infra_config_arn"></a> [imagebuilder\_infra\_config\_arn](#output\_imagebuilder\_infra\_config\_arn) | The ARN of the Imagebuilder infrastructure configuration. |
| <a name="output_imagebuilder_pipeline_arn"></a> [imagebuilder\_pipeline\_arn](#output\_imagebuilder\_pipeline\_arn) | The ARN of the Imagebuilder pipeline. |
| <a name="output_imagebuilder_pipeline_id"></a> [imagebuilder\_pipeline\_id](#output\_imagebuilder\_pipeline\_id) | The ID of the Imagebuilder pipeline. |
| <a name="output_imagebuilder_recipe_arn"></a> [imagebuilder\_recipe\_arn](#output\_imagebuilder\_recipe\_arn) | The ARN of the Imagebuilder image recipe |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | The name of instance profile attached to the Imagebuilder. |

<!-- END_TF_DOCS -->