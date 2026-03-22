<!-- BEGIN_TF_DOCS -->
# ArcGIS Web Adaptor AMI Builder
Terraform module which creates custom AMIs with ArcGIS Web Adaptor pre-installed using AWS EC2 Image Builder.

This module provides automated AMI building for ArcGIS Web Adaptor 11.5 on Linux (RHEL 9) with Tomcat and HTTPS support.

Source can be found at https://github.com/pgetech/gis-enterprise-ami

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.78.0 |

## Overview

This module creates custom Amazon Machine Images (AMIs) with ArcGIS Web Adaptor software pre-installed and configured with Apache Tomcat and HTTPS support. It uses AWS EC2 Image Builder to automate the AMI creation process for Linux (RHEL 9).

### Features

- **Platform Support**: Linux (RHEL 9)
- **Automated Installation**: Silent installation with S3-hosted software
- **Java 17**: OpenJDK 17.0.13 installation
- **Apache Tomcat**: Version 9.0.106 with HTTPS enabled
- **SSL/TLS Configuration**: Self-signed certificates with proper keystore alias configuration
- **Security Hardening**: OS updates, firewall configuration (ports 80, 443, 8080), and service hardening
- **Multi-Component**: Supports both Web Adaptor and Workflow Manager installation
- **Testing Framework**: Local Docker testing and automated validation scripts
- **CloudWatch Integration**: Build logs and monitoring

## Usage

### Basic Usage

```hcl
module "arcgis_webadaptor_ami" {
  source = "./arcgis-webadaptor/ami-build"

  # Project Configuration
  project     = "arcgis-enterprise"
  environment = "prod"

  # Software Configuration  
  arcgis_version = "11.5"
  java_version   = "17.0.13"
  tomcat_version = "9.0.106"

  # S3 Configuration
  deployment_bucket           = "arcgis-software-bucket"
  java_openjdk_17_key_name   = "software/java/openjdk-17.0.13_linux-x64_bin.tar.gz"
  tomcat_key_name            = "software/tomcat/apache-tomcat-9.0.106.tar.gz"
  webadaptor_installer_key_name = "software/arcgis/ArcGIS_Web_Adaptor_Linux_115.tar.gz"

  # SSL Configuration
  ssl_cert_password = "changeit"

  # Network Configuration
  subnet_id = "subnet-12345678"
  
  # Build Configuration
  instance_type        = "m5.large"
  instance_volume_size = 50
}
```

### Deployment Steps

1. Copy and customize configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

2. Initialize and validate:
   ```bash
   terraform init
   terraform validate
   terraform plan -var-file=terraform-dev.tfvars
   ```

3. Deploy the infrastructure:
   ```bash
   terraform apply -var-file=terraform-dev.tfvars
   ```

4. Build the AMI:
   ```bash
   # The pipeline will automatically build the AMI
   # Monitor progress in AWS Console → EC2 Image Builder
   ```

5. Test locally with Docker (optional):
   ```bash
   # Test the installation scripts locally before building AMI
   ./test-docker-local.sh
   ```

## Architecture

The module creates the following AWS resources:

- **EC2 Image Builder Components**: Custom installation component for ArcGIS Web Adaptor
- **Image Recipe**: Build process for RHEL 9 with Java 17, Tomcat 9, and Web Adaptor
- **Infrastructure Configuration**: Build instance specifications and IAM roles
- **Distribution Configuration**: Multi-region AMI distribution settings
- **Image Pipeline**: Orchestrated build workflow with validation
- **CloudWatch Resources**: Log groups for build process monitoring

### Installation Process

The Image Builder component executes the following steps:

1. **UpdateOS**: Updates RHEL packages (excludes amazon-ssm-agent)
2. **InstallDependencies**: Installs required packages (wget, jq, openssl, firewalld, etc.)
3. **ConfigureUsers**: Creates `arcgis` (UID 1100) and `tomcat` (UID 1101) users
4. **CreateDirectories**: Sets up `/opt/arcgis` and `/opt/software` structure
5. **DownloadSoftware**: Downloads Java, Tomcat, and ArcGIS software from S3
6. **InstallJava**: Installs OpenJDK 17.0.13 and configures JAVA_HOME
7. **InstallTomcat**: Installs Apache Tomcat 9.0.106
8. **ConfigureTomcatHttps**: 
   - Generates self-signed SSL certificate (800-day validity)
   - Creates JKS keystore with "tomcat" alias
   - Configures server.xml with HTTPS connector on port 443
   - Sets up HTTP connector on port 80
9. **ConfigureTomcatService**: Creates systemd service for Tomcat auto-start
10. **InstallArcGISWebAdaptor**: Silent installation of Web Adaptor
11. **ValidateInstallation**: Verifies successful installation and HTTPS connectivity

## Prerequisites

1. **S3 Bucket**: Containing ArcGIS Web Adaptor software installers
2. **VPC and Subnet**: With internet access for software downloads
3. **Required Software in S3**:
   - OpenJDK 17.0.13 tarball
   - Apache Tomcat 9.0.106 tarball
   - ArcGIS Web Adaptor 11.5 installer
   - (Optional) ArcGIS Workflow Manager installer

## Testing

### Local Docker Testing

Test the installation process locally before building the AMI:

```bash
# Quick start - automated setup
./test-docker-local.sh

# Or use Docker Compose
docker-compose up -d
docker exec -it arcgis-webadaptor-test /opt/test-install.sh
docker exec arcgis-webadaptor-test /opt/validate-ami.sh
```

See [DOCKER_TESTING.md](DOCKER_TESTING.md) for complete Docker testing guide.

### AMI Validation

After the AMI is built, launch a test instance and run:

```bash
# Copy validation script to instance
scp validate-ami.sh ec2-user@<instance-ip>:~

# SSH and run validation
ssh ec2-user@<instance-ip>
sudo ./validate-ami.sh
```

The validation script checks:
- Java installation and configuration
- Tomcat installation and service status
- HTTPS/SSL configuration
- Keystore with correct "tomcat" alias
- Port bindings (80, 443)
- SSL certificate validity
- ArcGIS Web Adaptor installation
- File permissions and ownership

See [TEST_AMI_BUILD.md](TEST_AMI_BUILD.md) for comprehensive testing guide.

## Key Resources

| Name | Type | Description |
|------|------|-------------|
| [aws_imagebuilder_component.webadaptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_component) | resource | Linux Web Adaptor installation component |
| [aws_imagebuilder_image_recipe.webadaptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_recipe) | resource | Linux image build recipe |
| [aws_imagebuilder_infrastructure_configuration.webadaptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_infrastructure_configuration) | resource | Build instance configuration |
| [aws_imagebuilder_distribution_configuration.webadaptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_distribution_configuration) | resource | AMI distribution settings |
| [aws_imagebuilder_image_pipeline.webadaptor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) | resource | Linux AMI build pipeline |
| [aws_iam_role.imagebuilder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | IAM role for Image Builder |
| [aws_iam_instance_profile.imagebuilder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource | Instance profile for build instances |

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_bucket"></a> [deployment\_bucket](#input\_deployment\_bucket) | S3 bucket containing ArcGIS software installers | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for build instance (must have internet access) | `string` | n/a | yes |
| <a name="input_java_openjdk_17_key_name"></a> [java\_openjdk\_17\_key\_name](#input\_java\_openjdk\_17\_key\_name) | S3 key for OpenJDK 17 tarball | `string` | n/a | yes |
| <a name="input_tomcat_key_name"></a> [tomcat\_key\_name](#input\_tomcat\_key\_name) | S3 key for Tomcat tarball | `string` | n/a | yes |
| <a name="input_webadaptor_installer_key_name"></a> [webadaptor\_installer\_key\_name](#input\_webadaptor\_installer\_key\_name) | S3 key for Web Adaptor installer | `string` | n/a | yes |

## Key Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | Project name for resource tagging | `string` | `"arcgis-enterprise"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_arcgis_version"></a> [arcgis\_version](#input\_arcgis\_version) | ArcGIS Web Adaptor version | `string` | `"11.5"` | no |
| <a name="input_java_version"></a> [java\_version](#input\_java\_version) | Java JDK version | `string` | `"17.0.13"` | no |
| <a name="input_tomcat_version"></a> [tomcat\_version](#input\_tomcat\_version) | Apache Tomcat version | `string` | `"9.0.106"` | no |
| <a name="input_ssl_cert_password"></a> [ssl\_cert\_password](#input\_ssl\_cert\_password) | Password for SSL certificate and keystore | `string` | `"changeit"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for building the AMI | `string` | `"m5.large"` | no |
| <a name="input_instance_volume_size"></a> [instance\_volume\_size](#input\_instance\_volume\_size) | Root volume size in GB for build instance | `number` | `50` | no |
| <a name="input_build_timeout_minutes"></a> [build\_timeout\_minutes](#input\_build\_timeout\_minutes) | Build timeout in minutes | `number` | `720` | no |
| <a name="input_enable_instance_tests"></a> [enable\_instance\_tests](#input\_enable\_instance\_tests) | Enable instance testing before AMI creation | `bool` | `true` | no |
| <a name="input_target_regions"></a> [target\_regions](#input\_target\_regions) | List of regions to distribute the AMI to | `list(string)` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | Latest AMI ID created by the pipeline |
| <a name="output_pipeline_arn"></a> [pipeline\_arn](#output\_pipeline\_arn) | ARN of the AMI pipeline |
| <a name="output_component_arn"></a> [component\_arn](#output\_component\_arn) | ARN of the Web Adaptor installation component |
| <a name="output_infrastructure_configuration_arn"></a> [infrastructure\_configuration\_arn](#output\_infrastructure\_configuration\_arn) | ARN of the infrastructure configuration |
| <a name="output_distribution_configuration_arn"></a> [distribution\_configuration\_arn](#output\_distribution\_configuration\_arn) | ARN of the distribution configuration |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Name of the IAM instance profile used by Image Builder |

## S3 Bucket Structure

Your deployment bucket should be organized as follows:

```
your-bucket/
├── software/
│   ├── java/
│   │   └── openjdk-17.0.13_linux-x64_bin.tar.gz
│   ├── tomcat/
│   │   └── apache-tomcat-9.0.106.tar.gz
│   └── arcgis/
│       ├── ArcGIS_Web_Adaptor_Linux_115_*.tar.gz
│       └── ArcGIS_Workflow_Manager_Linux_115_*.tar.gz (optional)
```

## Configuration Details

### Tomcat HTTPS Configuration

The build process automatically configures Tomcat with HTTPS support:

- **HTTP Port**: 80 (production) or 8080 (development)
- **HTTPS Port**: 443 (production) or 8443 (development)
- **SSL Certificate**: Self-signed certificate with 800-day validity
- **Keystore**: JKS format with "tomcat" alias
- **Certificate Details**: 
  - Subject: `/C=US/ST=State/L=City/O=Organization/OU=IT Department/CN=<hostname>`
  - Algorithm: RSA 2048-bit
  - Signature: SHA-256

### Firewall Configuration

The following ports are opened in firewalld:

- **Port 80**: HTTP traffic
- **Port 443**: HTTPS traffic  
- **Port 8080**: HTTP (development/testing)

### Service Configuration

Tomcat is configured as a systemd service with:

- Auto-start on boot
- Java heap: `-Xms512M -Xmx1024M`
- JVM options: Headless mode, secure random
- User/Group: tomcat:tomcat
- Restart policy: Always (after 10 seconds)

## Monitoring

### Build Status
- AWS Console → EC2 Image Builder → Image pipelines
- CloudWatch Logs: `/aws/imagebuilder/<component-name>`
- Build artifacts and logs stored in S3

### Logs
- Component execution logs in CloudWatch
- Tomcat logs: `/opt/tomcat-<version>/logs/catalina.out`
- System logs: `/var/log/messages`

### Validation

The build includes automated validation that checks:
- Web Adaptor WAR file exists: `/opt/arcgis/webadaptor<version>/java/arcgis.war`
- Tomcat installation: `/opt/tomcat-<version>/bin/catalina.sh`
- HTTPS connectivity test on port 443
- Expected HTTP response codes: 200, 403, 404 (all indicate working Tomcat)

## Troubleshooting

### Common Issues

**Issue**: keytool command not found  
**Solution**: Ensure JAVA_HOME is set in the same shell script block

**Issue**: HTTPS not working after AMI launch  
**Solution**: Verify keystore has "tomcat" alias and server.xml has certificateKeyAlias

**Issue**: Tomcat fails to start  
**Solution**: Check `/opt/tomcat-*/logs/catalina.out` for SSL connector errors

**Issue**: Build timeout  
**Solution**: Increase `build_timeout_minutes` variable or check network connectivity

**Issue**: S3 download fails  
**Solution**: Verify IAM role permissions and S3 key paths

### Debug Scripts

The repository includes helpful diagnostic scripts:

- **`validate-ami.sh`**: Comprehensive AMI validation
- **`test-docker-local.sh`**: Local Docker testing
- **`configure-tomcat-https.sh`**: Manual HTTPS configuration

See [DOCKER_TESTING.md](DOCKER_TESTING.md) and [TEST_AMI_BUILD.md](TEST_AMI_BUILD.md) for details.

## Examples

### Example terraform.tfvars

```hcl
# Project Configuration
project     = "arcgis-enterprise"
environment = "dev"

# Software Versions
arcgis_version = "11.5"
java_version   = "17.0.13"
tomcat_version = "9.0.106"

# S3 Configuration
deployment_bucket             = "my-arcgis-software-bucket"
java_openjdk_17_key_name     = "software/java/openjdk-17.0.13_linux-x64_bin.tar.gz"
tomcat_key_name              = "software/tomcat/apache-tomcat-9.0.106.tar.gz"
webadaptor_installer_key_name = "software/arcgis/ArcGIS_Web_Adaptor_Linux_115_189341.tar.gz"
workflow_installer_key_name   = "software/arcgis/ArcGIS_Workflow_Manager_Linux_115_189341.tar.gz"

# SSL Configuration
ssl_cert_password = "your-secure-password"

# Network Configuration
subnet_id = "subnet-0123456789abcdef0"

# Build Configuration
instance_type        = "m5.large"
instance_volume_size = 50
build_timeout_minutes = 720
```

### Testing Workflow Example

```bash
# 1. Test locally with Docker first
cd arcgis-webadaptor/ami-build
./test-docker-local.sh

# 2. Copy software to container
docker cp ~/software/java.tar.gz arcgis-webadaptor-test:/opt/software/java/17.0.13/java_openjdk.tar.gz
docker cp ~/software/tomcat.tar.gz arcgis-webadaptor-test:/opt/software/tomcat/9.0.106/apache-tomcat.tar.gz

# 3. Run installation test
docker exec -it arcgis-webadaptor-test /opt/test-install.sh

# 4. Validate locally
docker exec arcgis-webadaptor-test /opt/validate-ami.sh

# 5. Test HTTPS from host
curl -k https://localhost:8443/

# 6. If local tests pass, deploy to AWS
terraform init
terraform apply -var-file=terraform-dev.tfvars

# 7. After AMI builds, launch test instance and validate
# Copy validate-ami.sh to instance and run
```

## Related Documentation

- [DOCKER_TESTING.md](DOCKER_TESTING.md) - Comprehensive Docker testing guide
- [TEST_AMI_BUILD.md](TEST_AMI_BUILD.md) - Full AMI testing workflow
- [configure-tomcat-https.sh](configuration/scripts/11.5/configure-tomcat-https.sh) - HTTPS configuration script

## Support

For issues specific to:
- **Tomcat HTTPS**: Check keystore alias configuration and server.xml
- **Image Builder**: Review CloudWatch logs for component execution
- **ArcGIS Web Adaptor**: Consult Esri documentation for version 11.5

<!-- END_TF_DOCS -->