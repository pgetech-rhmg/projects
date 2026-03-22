# Trigger existing SSM document after Terraform stack completion

# Data source to get the existing SSM document
data "aws_ssm_document" "arcgisserver_config" {
  name            = "arcgis-server-11-5-configure"  # Your existing SSM document name
  document_format = "YAML"
}

# Data source to find primary hosted arcgis server instances by tags
data "aws_instances" "primary_hosted_arcgisserver" {
  filter {
    name   = "tag:Name"
    values = [var.hostedservermachinename]
  }

  filter {
    name   = "tag:ServerRole"
    values = ["Primary"]
  }

  filter {
    name   = "tag:SoftwareComponent"
    values = ["arcgisserver"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  # Ensure instances exist before trying to trigger
  depends_on = [
    module.hosted-server-ec2,
    aws_iam_role_policy.terraform_ssm_permissions  # Wait for IAM permissions
  ]
}
# Data source to find primary ENT arcgis server instances by tags
data "aws_instances" "primary_ent_arcgisserver" {
  filter {
    name   = "tag:Name"
    values = [var.entservermachinename]
  }

  filter {
    name   = "tag:ServerRole"
    values = ["Primary"]
  }

  filter {
    name   = "tag:SoftwareComponent"
    values = ["arcgisserver"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  # Ensure instances exist before trying to trigger
  depends_on = [
    module.arcgis-server-ec2-ent-primary,
    aws_iam_role_policy.terraform_ssm_permissions  # Wait for IAM permissions
  ]
}

# Trigger SSM on Primary hosted ArcGIS Server after stack is complete
resource "null_resource" "trigger_primary_hosted_arcgisserver_config" {

  # Ensure this runs after all critical resources are created
  depends_on = [
    module.hosted-server-ec2,          # Hosted Server EC2 instance
    aws_iam_role_policy.terraform_ssm_permissions  # Wait for IAM permissions
  ]

  # Trigger on resource changes
  triggers = {
    instance_ids      = join(",", data.aws_instances.primary_hosted_arcgisserver.ids)
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for instances to be in running state
      sleep 60
      for instance_id in ${join(" ", data.aws_instances.primary_hosted_arcgisserver.ids)}; do
        echo "Checking status of instance $instance_id..."
        for i in {1..10}; do
          status=$(aws ec2 describe-instance-status \
            --region ${var.aws_region} \
            --instance-ids $instance_id \
            --include-all-instances \
            --query 'InstanceStatuses[0].InstanceStatus.Status' \
            --output text 2>/dev/null || echo "initializing")
          
          if [ "$status" = "ok" ]; then
            echo "Instance $instance_id is ready"
            break
          else
            echo "Instance $instance_id status: $status - waiting 10 seconds..."
            sleep 10
          fi
        done
      done

      # Send SSM command
      aws ssm send-command \
        --region ${var.aws_region} \
        --document-name "${data.aws_ssm_document.arcgisserver_config.name}" \
        --instance-ids ${join(" ", data.aws_instances.primary_hosted_arcgisserver.ids)} \
        --parameters '{
          "Region": ["${var.aws_region}"],
          "DeploymentBucket": ["${var.bucket_name}"],
          "ServerAdminUser": ["${var.server_admin_user}"],
          "ServerAdminPassword": ["${random_password.server_admin_password.result}"],
          "LicenseFileS3Key": ["${var.server_license_file_s3_key}"],
          "EfsId": ["${module.hosted-efs.efs_id}"],
          "SiteDomain": ["${var.domain_name}"],
          "PortalAdminUser": ["${var.portal_admin_user}"],
          "PortalAdminPassword": ["${random_password.portal_admin_password.result}"],
          "WebAdaptorName": ["${var.server_webadaptor_name_hosted}"],
          "SslCertPassword": ["${var.portal_ssl_cert_password}"],
          "SslCertFileS3Key": ["${var.portal_ssl_cert_file_s3_key}"],
          "WorkflowManager": ["true"],
          "ArcGISVersion":["11.5"],
          "ServerRole":["Primary"],
          "InstanceID": ["${module.hosted-server-ec2.id}"],
          "PrivateIP": ["${module.hosted-server-ec2.private_ip}"],
          "PrimaryServerDNSName": ["${module.hosted-server-ec2.private_dns}"]
        }' \
        --comment "Terraform-triggered Primary Hosted ArcGIS Server configuration"
    EOT

    interpreter = ["bash", "-c"]
  }
}

# Trigger SSM on Primary ENT ArcGIS Server after stack is complete
resource "null_resource" "trigger_primary_ent_arcgisserver_config" {

  # Ensure this runs after all critical resources are created
  depends_on = [
    module.arcgis-server-ec2-ent-primary,        # ENT Server EC2 instance
    aws_iam_role_policy.terraform_ssm_permissions  # Wait for IAM permissions
  ]

  # Trigger on resource changes
  triggers = {
    instance_ids      = join(",", data.aws_instances.primary_ent_arcgisserver.ids)
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 60
      for instance_id in ${join(" ", data.aws_instances.primary_ent_arcgisserver.ids)}; do
        echo "Checking status of instance $instance_id..."
        for i in {1..10}; do
          status=$(aws ec2 describe-instance-status \
            --region ${var.aws_region} \
            --instance-ids $instance_id \
            --include-all-instances \
            --query 'InstanceStatuses[0].InstanceStatus.Status' \
            --output text 2>/dev/null || echo "initializing")
          
          if [ "$status" = "ok" ]; then
            echo "Instance $instance_id is ready"
            break
          else
            echo "Instance $instance_id status: $status - waiting 10 seconds..."
            sleep 10
          fi
        done
      done
      aws ssm send-command \
        --region ${var.aws_region} \
        --document-name "${data.aws_ssm_document.arcgisserver_config.name}" \
        --instance-ids ${join(" ", data.aws_instances.primary_ent_arcgisserver.ids)} \
        --parameters '{
          "Region": ["${var.aws_region}"],
          "DeploymentBucket": ["${var.bucket_name}"],
          "ServerAdminUser": ["${var.server_admin_user}"],
          "ServerAdminPassword": ["${random_password.server_admin_password.result}"],
          "LicenseFileS3Key": ["${var.server_license_file_s3_key}"],
          "EfsId": ["${module.arcgis-server-efs-ent.efs_id}"],
          "SiteDomain": ["${var.domain_name}"],
          "PortalAdminUser": ["${var.portal_admin_user}"],
          "PortalAdminPassword": ["${random_password.portal_admin_password.result}"],
          "WebAdaptorName": ["${var.server_webadaptor_name_ent}"],
          "SslCertPassword": ["${var.portal_ssl_cert_password}"],
          "SslCertFileS3Key": ["${var.portal_ssl_cert_file_s3_key}"],
          "WorkflowManager": ["false"],
          "ArcGISVersion":["11.5"],
          "ServerRole":["Primary"],
          "InstanceID": ["${module.arcgis-server-ec2-ent-primary.id}"],
          "PrivateIP": ["${module.arcgis-server-ec2-ent-primary.private_ip}"],
          "PrimaryServerDNSName": ["${module.arcgis-server-ec2-ent-primary.private_dns}"]
        }' \
        --comment "Terraform-triggered Primary ENT ArcGIS Server configuration"
    EOT

    interpreter = ["bash", "-c"]
  }
}
