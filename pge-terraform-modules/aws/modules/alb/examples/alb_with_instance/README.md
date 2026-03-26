<!-- BEGIN_TF_DOCS -->
# AWS ALB  module
Terraform module which creates SAF2.0 ALB in AWS.
alb logs cannot be written to a kms-cmk encrypted s3 bucket.
So standard encryption is used for the s3 bucket.
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html

For this example we are using the S3 bucket, SSL certificate arn and ingress CIDR, which already exists in this account.
If the user is testing the example in a different account,  please change the S3 bucket name, SSL certificate arn
and ingress CIDR as per the account.

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
| <a name="module_alb"></a> [alb](#module\_alb) | ../../ | n/a |
| <a name="module_alb_security_group"></a> [alb\_security\_group](#module\_alb\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_ec2_1"></a> [ec2\_1](#module\_ec2\_1) | app.terraform.io/pgetech/ec2/aws | 0.1.1 |
| <a name="module_ec2_2"></a> [ec2\_2](#module\_ec2\_2) | app.terraform.io/pgetech/ec2/aws | 0.1.1 |
| <a name="module_ec2_security_group_1"></a> [ec2\_security\_group\_1](#module\_ec2\_security\_group\_1) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_ec2_security_group_2"></a> [ec2\_security\_group\_2](#module\_ec2\_security\_group\_2) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ssm_parameter.golden_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

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
| <a name="input_alb_cidr_ingress_rules"></a> [alb\_cidr\_ingress\_rules](#input\_alb\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the alb on AWS | `string` | n/a | yes |
| <a name="input_alb_sg_description"></a> [alb\_sg\_description](#input\_alb\_sg\_description) | Security group for example usage with alb | `string` | n/a | yes |
| <a name="input_alb_sg_name"></a> [alb\_sg\_name](#input\_alb\_sg\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the s3 bucket to store alb logs on AWS | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The ARN of the certificate to attach to the listener. | `list(map(string))` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_ec2_az"></a> [ec2\_az](#input\_ec2\_az) | List of availability zone for ec2 | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | type of the ec2 instance | `string` | n/a | yes |
| <a name="input_ec2_name_1"></a> [ec2\_name\_1](#input\_ec2\_name\_1) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_ec2_name_2"></a> [ec2\_name\_2](#input\_ec2\_name\_2) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_lb_listener_http"></a> [lb\_listener\_http](#input\_lb\_listener\_http) | A list of maps describing HTTP listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | A list of maps describing HTTPS listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_listener_rule_http"></a> [lb\_listener\_rule\_http](#input\_lb\_listener\_rule\_http) | A list of maps describing the listener rules for ALB. | `any` | n/a | yes |
| <a name="input_lb_listener_rule_https"></a> [lb\_listener\_rule\_https](#input\_lb\_listener\_rule\_https) | A list of maps describing the listener rules for ALB. | `any` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | Policy template file in json format | `string` | `"s3_policy.json"` | no |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | Security group for example usage with EC2 | `string` | n/a | yes |
| <a name="input_sg_name_1"></a> [sg\_name\_1](#input\_sg\_name\_1) | Name of the security group | `string` | n/a | yes |
| <a name="input_sg_name_2"></a> [sg\_name\_2](#input\_sg\_name\_2) | Name of the security group | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | The ARN of the load balancer (matches id). |
| <a name="output_lb_arn_suffix"></a> [lb\_arn\_suffix](#output\_lb\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | The id of the load balancer (matches arn). |
| <a name="output_lb_listener_certificate"></a> [lb\_listener\_certificate](#output\_lb\_listener\_certificate) | The listener\_arn and certificate\_arn separated by a \_. |
| <a name="output_lb_target_group_attachment_id"></a> [lb\_target\_group\_attachment\_id](#output\_lb\_target\_group\_attachment\_id) | A unique identifier for the attachment. |
| <a name="output_lb_zone_id"></a> [lb\_zone\_id](#output\_lb\_zone\_id) | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |
| <a name="output_listener_http_arn"></a> [listener\_http\_arn](#output\_listener\_http\_arn) | ARN of the listener (matches id). |
| <a name="output_listener_https_arn"></a> [listener\_https\_arn](#output\_listener\_https\_arn) | ARN of the listener (matches id). |
| <a name="output_listener_rule_http_id"></a> [listener\_rule\_http\_id](#output\_listener\_rule\_http\_id) | ARN of the listener (matches arn). |
| <a name="output_listener_rule_https_id"></a> [listener\_rule\_https\_id](#output\_listener\_rule\_https\_id) | ARN of the listener (matches arn). |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the Target Group (matches id). |

<!-- END_TF_DOCS -->