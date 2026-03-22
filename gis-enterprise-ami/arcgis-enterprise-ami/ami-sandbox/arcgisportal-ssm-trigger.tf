# Trigger existing SSM document after Terraform stack completion

# Data source to get the existing SSM document
data "aws_ssm_document" "arcgisportal_config" {
  name            = "arcgis-portal-11-5-configure"  # Your existing SSM document name
  document_format = "YAML"
}

# Data source to find Primary Portal instances by tags
data "aws_instances" "primary_portal" {
  filter {
    name   = "tag:Name"
    values = [var.portalmachinename]
  }

  filter {
    name   = "tag:PortalRole"
    values = ["Primary"]
  }

  filter {
    name   = "tag:SoftwareComponent"
    values = ["arcgisportal"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  # Ensure instances exist before trying to trigger
  depends_on = [
    module.portal-ec2-primary,
    aws_iam_role_policy.terraform_ssm_permissions  # Wait for IAM permissions
  ]
}

# Trigger SSM on Primary Portal after stack is complete
resource "null_resource" "trigger_primary_portal_config" {

  # Ensure this runs after all critical resources are created
  depends_on = [
    module.portal-ec2-primary,        # Web Adaptor EC2 instance
    aws_iam_role_policy.terraform_ssm_permissions  # Wait for IAM permissions
  ]

  # Trigger on resource changes
  triggers = {
    instance_ids      = join(",", data.aws_instances.primary_portal.ids)
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 60
      for instance_id in ${join(" ", data.aws_instances.primary_portal.ids)}; do
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
        --document-name "${data.aws_ssm_document.arcgisportal_config.name}" \
        --instance-ids ${join(" ", data.aws_instances.primary_portal.ids)} \
        --parameters '{
          "Region": ["${var.aws_region}"],
          "DeploymentBucket": ["${var.bucket_name}"],
          "PortalAdminUser": ["${var.portal_admin_user}"],
          "PortalAdminPassword": ["${random_password.portal_admin_password.result}"],
          "PortalLicenseFileS3Key": ["${var.portal_license_file_s3_key}"],
          "SiteDomain": ["${var.domain_name}"],
          "EfsId": ["${module.portal-efs.efs_id}"],
          "PortalWebAdaptorName": ["${var.portal_webadaptor_name}"],
          "PortalAdminUser": ["${var.portal_admin_user}"],
          "SslCertFileS3Key": ["${var.portal_ssl_cert_file_s3_key}"],
          "SslCertPassword": ["${var.portal_ssl_cert_password}"],
          "PortalRole":["Primary"],
          "InstanceID": ["${module.portal-ec2-primary.id}"],
          "PrivateIP": ["${module.portal-ec2-primary.private_ip}"],
          "PrimaryPortalDNSName": ["${module.portal-ec2-primary.private_dns}"]
        }' \
        --comment "Terraform-triggered Primary Portal configuration"
    EOT

    interpreter = ["bash", "-c"]
  }
}

