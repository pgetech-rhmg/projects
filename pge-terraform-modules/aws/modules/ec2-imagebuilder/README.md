<!-- BEGIN_TF_DOCS -->
# AWS EC2 Image Builder Module

Terraform module which creates and manages AWS EC2 Image Builder resources such as image pipelines, recipes, and infrastructure configurations.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |

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
| <a name="module_aws_lambda_iam_role"></a> [aws\_lambda\_iam\_role](#module\_aws\_lambda\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_custom_kms_secrets_policy"></a> [custom\_kms\_secrets\_policy](#module\_custom\_kms\_secrets\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_email_sns_topic"></a> [email\_sns\_topic](#module\_email\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_image_builder_sg"></a> [image\_builder\_sg](#module\_image\_builder\_sg) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_imagebuilder_component"></a> [imagebuilder\_component](#module\_imagebuilder\_component) | ./modules/imagebuilder_component | n/a |
| <a name="module_imagebuilder_get_component_policy"></a> [imagebuilder\_get\_component\_policy](#module\_imagebuilder\_get\_component\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_imagebuilder_instance_role"></a> [imagebuilder\_instance\_role](#module\_imagebuilder\_instance\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_imagebuilder_service_role"></a> [imagebuilder\_service\_role](#module\_imagebuilder\_service\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_imagebuilder_sns_topic"></a> [imagebuilder\_sns\_topic](#module\_imagebuilder\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_lambda_execution_role"></a> [lambda\_execution\_role](#module\_lambda\_execution\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_lambda_function_policy"></a> [lambda\_function\_policy](#module\_lambda\_function\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_lambda_security_group"></a> [lambda\_security\_group](#module\_lambda\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_sns_message_processor"></a> [sns\_message\_processor](#module\_sns\_message\_processor) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_sns_topic_subscription"></a> [sns\_topic\_subscription](#module\_sns\_topic\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.1 |
| <a name="module_sns_topic_subscription_imagebuilder"></a> [sns\_topic\_subscription\_imagebuilder](#module\_sns\_topic\_subscription\_imagebuilder) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.1 |
| <a name="module_ssm_automation_role"></a> [ssm\_automation\_role](#module\_ssm\_automation\_role) | app.terraform.io/pgetech/iam/aws | 0.1.0 |
| <a name="module_ssm_document_policy"></a> [ssm\_document\_policy](#module\_ssm\_document\_policy) | app.terraform.io/pgetech/iam/aws//modules/iam_policy | 0.1.1 |
| <a name="module_update_stackset_lambda"></a> [update\_stackset\_lambda](#module\_update\_stackset\_lambda) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role_policy_attachment.automation_lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_document_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_imagebuilder_distribution_configuration.with_license](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration) | resource |
| [aws_imagebuilder_distribution_configuration.without_license](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration) | resource |
| [aws_imagebuilder_image.image_builder_img](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image) | resource |
| [aws_imagebuilder_image_pipeline.imagebuilder_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) | resource |
| [aws_imagebuilder_image_recipe.image_recipe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_recipe) | resource |
| [aws_imagebuilder_infrastructure_configuration.imagebuilder_infra_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_infrastructure_configuration) | resource |
| [aws_lambda_permission.sns_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_ssm_document.automation_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [archive_file.lambda_package](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.get_component_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.ami_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.approver_topic_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.beta_ami_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.cmk_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.cmk_ebs_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.encrypted_ami_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.non_prod_ami_sns_topic_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.nonprod_ami_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.parent_image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.prev_ami_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.status_ami_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id_az_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id_az_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id_az_c](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_imagebuilder_distribution_configuration.image_builder_dist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration) | resource |
| [aws_imagebuilder_image.image_builder_img](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image) | resource |
| [aws_imagebuilder_image_pipeline.imagebuilder_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) | resource |
| [aws_imagebuilder_image_recipe.image_recipe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_recipe) | resource |
| [aws_imagebuilder_infrastructure_configuration.imagebuilder_infra_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_infrastructure_configuration) | resource |
| [aws_lambda_function.sns_message_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.sns_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.lambda_package](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.get_component_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_ami_name"></a> [ami\_name](#input\_ami\_name) | Name format for distribution AMI. Use variables like {{imagebuilder:buildDate}} if required | `string` | n/a | yes |
| <a name="input_ami_parameter_store"></a> [ami\_parameter\_store](#input\_ami\_parameter\_store) | Name of parameter store for the golden AMI | `string` | `"/ami/linux/golden"` | no |
| <a name="input_ami_parameter_store_status"></a> [ami\_parameter\_store\_status](#input\_ami\_parameter\_store\_status) | Status of AMI parameter store | `string` | n/a | yes |
| <a name="input_ami_regions_kms_key"></a> [ami\_regions\_kms\_key](#input\_ami\_regions\_kms\_key) | Map of KMS key ARN for AMI encryption per region | `map(string)` | `{}` | no |
| <a name="input_ami_tags"></a> [ami\_tags](#input\_ami\_tags) | Tags to apply for distributed AMI | `map(string)` | `{}` | no |
| <a name="input_approver_arns"></a> [approver\_arns](#input\_approver\_arns) | A list of AWS authenticated principals who are eligible to either approve or reject the AMI Distribution action. | `list(string)` | <pre>[<br/>  "arn:aws:sts::686137062481:assumed-role/SuperAdmin/SCLF@utility.pge.com",<br/>  "arn:aws:sts::686137062481:assumed-role/SuperAdmin/A2VB@utility.pge.com"<br/>]</pre> | no |
| <a name="input_approver_topic_arn"></a> [approver\_topic\_arn](#input\_approver\_topic\_arn) | ARN of the Image builder approver SNS topic | `string` | `"/ami/base-linux/approver/topic/arn"` | no |
| <a name="input_aws_owned_component_arn"></a> [aws\_owned\_component\_arn](#input\_aws\_owned\_component\_arn) | ARN of AWS provide component | `list(string)` | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the resource need to be created | `string` | n/a | yes |
| <a name="input_block_device_iops"></a> [block\_device\_iops](#input\_block\_device\_iops) | Provisioned IOPS for the block device (only for io1 or io2 types) | `number` | n/a | yes |
| <a name="input_block_device_throughput"></a> [block\_device\_throughput](#input\_block\_device\_throughput) | Throughput in MiB/s for gp3 volumes only. | `number` | `null` | no |
| <a name="input_change_description"></a> [change\_description](#input\_change\_description) | description of changes since last version | `string` | `null` | no |
| <a name="input_cmk_arn"></a> [cmk\_arn](#input\_cmk\_arn) | Parameter store of the CMK ARN for Lambda environment encryption | `string` | `"/servicekey/lambda"` | no |
| <a name="input_cmk_ebs_arn"></a> [cmk\_ebs\_arn](#input\_cmk\_ebs\_arn) | CMK ARN for EBS image encryption | `string` | `"/servicekey/ebs"` | no |
| <a name="input_component_data"></a> [component\_data](#input\_component\_data) | Map of component data that can either contain file path or data URI | `map(string)` | `{}` | no |
| <a name="input_component_description"></a> [component\_description](#input\_component\_description) | description of component | `string` | `null` | no |
| <a name="input_component_kms_key_id"></a> [component\_kms\_key\_id](#input\_component\_kms\_key\_id) | KMS key to use for encryption | `string` | `null` | no |
| <a name="input_component_name"></a> [component\_name](#input\_component\_name) | name to use for component | `string` | n/a | yes |
| <a name="input_component_platform"></a> [component\_platform](#input\_component\_platform) | platform of component(Linux or Windows) | `string` | `"Linux"` | no |
| <a name="input_component_supported_os_versions"></a> [component\_supported\_os\_versions](#input\_component\_supported\_os\_versions) | Aset of operating system versions supported by the component. If the os information is available, a prefix match is performed against the base image os version during image recipe creation. | `set(string)` | `null` | no |
| <a name="input_component_version"></a> [component\_version](#input\_component\_version) | version of the component | `string` | n/a | yes |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | (Optional) Create security group for EC2 Image Builder instances. Please note this security group will be created with default egress rule to 0.0.0.0/0 CIDR Block. In case you want to have a more restrict set of rules, please provide your own security group id on security\_group\_ids variable | `bool` | `true` | no |
| <a name="input_delete_on_termination_img_recipe"></a> [delete\_on\_termination\_img\_recipe](#input\_delete\_on\_termination\_img\_recipe) | Whether to delete the volume on instance termination | `bool` | n/a | yes |
| <a name="input_distribution_regions"></a> [distribution\_regions](#input\_distribution\_regions) | List of regions where the image should be distributed | `list(string)` | n/a | yes |
| <a name="input_ec2_imagebuilder_instance_types"></a> [ec2\_imagebuilder\_instance\_types](#input\_ec2\_imagebuilder\_instance\_types) | Instance type for EC2 instance used in the Imagebuilder. | `list(string)` | n/a | yes |
| <a name="input_enhanced_image_metadata_enabled"></a> [enhanced\_image\_metadata\_enabled](#input\_enhanced\_image\_metadata\_enabled) | Enable additional metadata collection of the AMI. | `bool` | `true` | no |
| <a name="input_execution_role"></a> [execution\_role](#input\_execution\_role) | ARN of the role for image builder execution. | `string` | n/a | yes |
| <a name="input_image_tests_enabled"></a> [image\_tests\_enabled](#input\_image\_tests\_enabled) | Whether to enable the Image test configuration. | `bool` | n/a | yes |
| <a name="input_imagebuilder_dist_description"></a> [imagebuilder\_dist\_description](#input\_imagebuilder\_dist\_description) | Description of the distribution configuration | `string` | `null` | no |
| <a name="input_instance_key_pair"></a> [instance\_key\_pair](#input\_instance\_key\_pair) | EC2 key pair to add to the default user on the builder(In case existent EC2 Key Pair is provided) | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN of KMS key used for encrypting the AMI | `string` | `null` | no |
| <a name="input_launch_permission_organization_arns"></a> [launch\_permission\_organization\_arns](#input\_launch\_permission\_organization\_arns) | List of AWS organization ARNs for AMI launch permission | `list(string)` | `[]` | no |
| <a name="input_launch_permission_organization_units_arn"></a> [launch\_permission\_organization\_units\_arn](#input\_launch\_permission\_organization\_units\_arn) | List of Organizational ARNs for AMI launch permissions. | `list(string)` | `[]` | no |
| <a name="input_launch_permission_user_ids"></a> [launch\_permission\_user\_ids](#input\_launch\_permission\_user\_ids) | List of AWS account ID's for AMI launch permissions. | `list(string)` | `[]` | no |
| <a name="input_launch_template_id"></a> [launch\_template\_id](#input\_launch\_template\_id) | The ID of EC2 launch template to associate with the AMI. | `string` | `null` | no |
| <a name="input_license_configuration_arn"></a> [license\_configuration\_arn](#input\_license\_configuration\_arn) | The ARN of the license configuration | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the project which will be used as a prefix for every resource. | `string` | n/a | yes |
| <a name="input_non_prod_ami_sns_topic_arn"></a> [non\_prod\_ami\_sns\_topic\_arn](#input\_non\_prod\_ami\_sns\_topic\_arn) | Parameter store name for the new AMI NonProd notification topic ARN | `string` | `"/ami/linux/new-ami/nonprod/topic/arn"` | no |
| <a name="input_notification_email"></a> [notification\_email](#input\_notification\_email) | Email address to receive notifications | `list(string)` | n/a | yes |
| <a name="input_parent_image_ssm_path"></a> [parent\_image\_ssm\_path](#input\_parent\_image\_ssm\_path) | SSM path of the base AMI for the image recipe | `string` | `"pge-base-linux-ami"` | no |
| <a name="input_pipeline_status"></a> [pipeline\_status](#input\_pipeline\_status) | Status of the pipeline whether to ENABLED or DISABLED | `string` | n/a | yes |
| <a name="input_receipients"></a> [receipients](#input\_receipients) | Email ID of Receipient | `list(string)` | `[]` | no |
| <a name="input_recipe_description"></a> [recipe\_description](#input\_recipe\_description) | Image Recipe description. | `string` | n/a | yes |
| <a name="input_recipe_version"></a> [recipe\_version](#input\_recipe\_version) | Version of the image recipe in semantic format. | `string` | `"0.0.2"` | no |
| <a name="input_recipe_volume_size"></a> [recipe\_volume\_size](#input\_recipe\_volume\_size) | Size of the volume for image recipe | `number` | `8` | no |
| <a name="input_recipe_volume_type"></a> [recipe\_volume\_type](#input\_recipe\_volume\_type) | Type of the volume for image recipe | `string` | `"gp3"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The S3 bucket name for storing logs of the EC2 Image Builder. | `string` | n/a | yes |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | "(Optional) pipeline\_execution\_start\_condition = The condition configures when the pipeline should trigger a new image build. <br/>Valid Values: EXPRESSION\_MATCH\_ONLY \| EXPRESSION\_MATCH\_AND\_DEPENDENCY\_UPDATES\_AVAILABLE<br/>scheduleExpression = The cron expression determines how often EC2 Image Builder evaluates your pipelineExecutionStartCondition.<br/>e.g.:  "cron(0 0 * * ? *)" | <pre>list(object({<br/>    pipeline_execution_start_condition = string,<br/>    scheduleExpression                 = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Custom Security group IDs for EC2 Image Builder instances(In case existent Security Group is provided) | `list(string)` | `[]` | no |
| <a name="input_sender"></a> [sender](#input\_sender) | Email ID of Sender | `string` | n/a | yes |
| <a name="input_ssm_document_name"></a> [ssm\_document\_name](#input\_ssm\_document\_name) | SSM Document Name | `string` | n/a | yes |
| <a name="input_ssm_document_version"></a> [ssm\_document\_version](#input\_ssm\_document\_version) | Version of the resources associated with the SSM Document | `string` | `"1"` | no |
| <a name="input_stack_set_name"></a> [stack\_set\_name](#input\_stack\_set\_name) | Name od StackSet to distribute the golden AMI | `string` | `"current-ami-id-linux-prod"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet id for launching the EC2 Image Builder instance | `string` | n/a | yes |
| <a name="input_subnet_id_az_a"></a> [subnet\_id\_az\_a](#input\_subnet\_id\_az\_a) | SSM Parameter that holds the subnet for Availability Zone A | `string` | `"/vpc/2/privatesubnet1/id"` | no |
| <a name="input_subnet_id_az_b"></a> [subnet\_id\_az\_b](#input\_subnet\_id\_az\_b) | SSM Parameter that holds the subnet for Availability Zone B | `string` | `"/vpc/2/privatesubnet2/id"` | no |
| <a name="input_subnet_id_az_c"></a> [subnet\_id\_az\_c](#input\_subnet\_id\_az\_c) | SSM Parameter that holds the subnet for Availability Zone C | `string` | `"/vpc/2/privatesubnet3/id"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of resource tags to associate with resource | `map(string)` | n/a | yes |
| <a name="input_target_accounts_table"></a> [target\_accounts\_table](#input\_target\_accounts\_table) | DynamoDB table of target accounts | `string` | n/a | yes |
| <a name="input_terminate_instance_on_failure"></a> [terminate\_instance\_on\_failure](#input\_terminate\_instance\_on\_failure) | Whether to terminate the builder instance on build failure | `bool` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Overall timeout for the image creation process in hours | `string` | `"2h"` | no |
| <a name="input_timeout_minutes"></a> [timeout\_minutes](#input\_timeout\_minutes) | Timeout in minutes for image test | `number` | `60` | no |
| <a name="input_uninstall_after_build"></a> [uninstall\_after\_build](#input\_uninstall\_after\_build) | Whether to uninstall the system manager agent after the image is built. | `bool` | n/a | yes |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | Base64 encoded user data for execution during the build process. | `string` | `null` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Cidr block for the VPC | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the EC2 Image Builder Environment. | `string` | n/a | yes |
| <a name="input_working_directory"></a> [working\_directory](#input\_working\_directory) | Working directory for build and test workflows | `string` | `null` | no | 


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_distribution_configuration"></a> [distribution\_configuration](#output\_distribution\_configuration) | EC2 Imagebuilder distribution configuration |
| <a name="output_iam_instance_profile"></a> [iam\_instance\_profile](#output\_iam\_instance\_profile) | EC2 Imagebuilder Instance Profile |
| <a name="output_image_builder_image_recipe_arn"></a> [image\_builder\_image\_recipe\_arn](#output\_image\_builder\_image\_recipe\_arn) | EC2 Imagebuilder Image Recipe ARN |
| <a name="output_image_builder_img"></a> [image\_builder\_img](#output\_image\_builder\_img) | EC2 Image Builder Image. |
| <a name="output_imagebuilder_image_pipeline"></a> [imagebuilder\_image\_pipeline](#output\_imagebuilder\_image\_pipeline) | EC2 Imagebuilder Image Pipeline |
| <a name="output_imagebuilder_security_group"></a> [imagebuilder\_security\_group](#output\_imagebuilder\_security\_group) | Imagebuilder security group |
| <a name="output_infrastructure_configuration"></a> [infrastructure\_configuration](#output\_infrastructure\_configuration) | EC2 Image Builder infrastructure configuration. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group created for Imagebuilder. |

<!-- END_TF_DOCS -->