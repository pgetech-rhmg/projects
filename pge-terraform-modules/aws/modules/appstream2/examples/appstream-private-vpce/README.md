# AppStream 2.0 Private Deployment with VPC Endpoints

This example demonstrates how to deploy AppStream 2.0 in a completely private environment using VPC endpoints for AWS service connectivity.

## Architecture Overview

This deployment creates:
- AppStream fleet in private subnets (no internet gateway)
- VPC endpoints for all required AWS services
- Security groups configured for VPC endpoint communication
- Access endpoints configured in the AppStream stack

## Required Infrastructure

### Network Requirements
- **VPC with private subnets only** (no internet gateway)
- **Route tables** associated with private subnets
- **NAT Gateway** (optional, only if image builders need software downloads)

### VPC Endpoints Created
1. **AppStream Streaming** - `com.amazonaws.region.appstream.streaming`
2. **S3 Gateway** - `com.amazonaws.region.s3` 
3. **EC2 Interface** - `com.amazonaws.region.ec2`
4. **CloudWatch Logs** - `com.amazonaws.region.logs`
5. **Systems Manager** - `com.amazonaws.region.ssm`

## Key Differences from Internet-based Deployment

### Security Groups
- Configured for VPC internal communication only
- HTTPS (443) allowed for VPC endpoint traffic
- AppStream streaming ports (1400-1499) for internal traffic

### Stack Configuration
- **access_endpoints** block configured to use VPC endpoint
- No internet gateway dependency
- All AWS service calls route through VPC endpoints

### Cost Considerations
- VPC endpoints incur hourly charges ($0.01/hour per endpoint)
- Data processing charges ($0.01/GB)
- Higher overall cost but improved security posture

## Prerequisites

1. **Private VPC Setup**:
   ```bash
   # Ensure your VPC has:
   # - Private subnets without internet gateway
   # - Route tables configured for VPC endpoints
   # - DNS resolution and DNS hostnames enabled
   ```

2. **SSM Parameters**:
   Update the following SSM parameters to point to private subnets:
   - `/vpc/private/id` - VPC ID without internet gateway
   - `/vpc/privatesubnet1/id` - Private subnet 1
   - `/vpc/privatesubnet2/id` - Private subnet 2
   - `/vpc/privatesubnet3/id` - Private subnet 3

3. **Domain Configuration**:
   Ensure Active Directory is accessible from private subnets

## Deployment Steps

1. **Update Variables**:
   ```bash
   # Edit terraform.auto.tfvars
   # Ensure SSM parameters point to private subnets
   ```

2. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Verify**:
   ```bash
   # Check VPC endpoints are created and in "Available" state
   # Verify AppStream fleet starts successfully
   # Test user connectivity through corporate network
   ```

## User Access

Users must connect through:
- **Corporate VPN** to AWS VPC
- **AWS Direct Connect** 
- **Transit Gateway** connection
- Any private network path to the VPC

Public internet users **cannot** access this deployment.

## Troubleshooting

### Common Issues

1. **Fleet fails to start**:
   - Check VPC endpoint status
   - Verify security group allows port 443
   - Ensure DNS resolution is enabled

2. **Users cannot connect**:
   - Verify access_endpoints configuration
   - Check corporate network routing to VPC
   - Confirm VPC endpoint DNS resolution

3. **High costs**:
   - Review VPC endpoint usage
   - Consider hybrid approach with some internet access
   - Monitor data transfer through endpoints

## Security Benefits

- **No internet exposure** - All traffic stays within AWS backbone
- **Network isolation** - Complete private connectivity
- **Compliance ready** - Meets strict security requirements
- **Audit friendly** - All traffic flows are predictable and logged
<!-- BEGIN_TF_DOCS -->
# AWS AppStream 2.0 with VPC Endpoints - Private Deployment Example
Terraform module for AppStream 2.0 with complete VPC endpoint setup for private connectivity
This example shows how to deploy AppStream without internet access using VPC endpoints

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

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
| <a name="module_fleet"></a> [fleet](#module\_fleet) | ../../modules/fleet | n/a |
| <a name="module_fleet_stack"></a> [fleet\_stack](#module\_fleet\_stack) | ../../modules/fleet_stack_association | n/a |
| <a name="module_iam_role_appstream"></a> [iam\_role\_appstream](#module\_iam\_role\_appstream) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_security_group_appstream"></a> [security\_group\_appstream](#module\_security\_group\_appstream) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_stack_appstream"></a> [stack\_appstream](#module\_stack\_appstream) | ../../modules/stack | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_vpc_endpoint.appstream_streaming](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.fleet_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.fleet_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.fleet_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

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
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_appstream_service_name"></a> [appstream\_service\_name](#input\_appstream\_service\_name) | AppStream streaming service name for VPC endpoint | `string` | `"com.amazonaws.us-west-2.appstream.streaming"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description to display | `string` | n/a | yes |
| <a name="input_desired_instances"></a> [desired\_instances](#input\_desired\_instances) | Desired number of streaming instances | `number` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Human-readable friendly name for the AppStream resources | `string` | n/a | yes |
| <a name="input_domain_join_info"></a> [domain\_join\_info](#input\_domain\_join\_info) | Configuration block for joining instances to Microsoft Active Directory domain | <pre>object({<br>    directory_name                         = string<br>    organizational_unit_distinguished_name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_fleet_type"></a> [fleet\_type](#input\_fleet\_type) | Fleet type. Valid values are: ON\_DEMAND, ALWAYS\_ON, ELASTIC | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the image used to create the fleet | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use when launching fleet instances | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Unique name for the AppStream resources | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_role_service"></a> [role\_service](#input\_role\_service) | AWS service for the IAM role | `list(string)` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | SSM parameter name storing private subnet ID 1 | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | SSM parameter name storing private subnet ID 2 | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id3"></a> [ssm\_parameter\_subnet\_id3](#input\_ssm\_parameter\_subnet\_id3) | SSM parameter name storing private subnet ID 3 | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | SSM parameter name storing the VPC ID for private subnets (no internet gateway) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appstream_fleet_arn"></a> [appstream\_fleet\_arn](#output\_appstream\_fleet\_arn) | ARN of the appstream fleet. |
| <a name="output_appstream_fleet_id"></a> [appstream\_fleet\_id](#output\_appstream\_fleet\_id) | Unique identifier (ID) of the appstream fleet. |
| <a name="output_appstream_fleet_state"></a> [appstream\_fleet\_state](#output\_appstream\_fleet\_state) | State of the fleet. |
| <a name="output_appstream_stack_arn"></a> [appstream\_stack\_arn](#output\_appstream\_stack\_arn) | ARN of the appstream stack. |
| <a name="output_appstream_stack_created_time"></a> [appstream\_stack\_created\_time](#output\_appstream\_stack\_created\_time) | Date and time, in UTC and extended RFC 3339 format, when the stack was created. |
| <a name="output_appstream_stack_id"></a> [appstream\_stack\_id](#output\_appstream\_stack\_id) | Unique ID of the appstream stack. |
| <a name="output_vpc_endpoint_appstream_dns_entry"></a> [vpc\_endpoint\_appstream\_dns\_entry](#output\_vpc\_endpoint\_appstream\_dns\_entry) | DNS entries for the AppStream VPC endpoint. |
| <a name="output_vpc_endpoint_appstream_id"></a> [vpc\_endpoint\_appstream\_id](#output\_vpc\_endpoint\_appstream\_id) | ID of the AppStream VPC endpoint. |


<!-- END_TF_DOCS -->