# Trigger existing SSM document after Terraform stack completion

# Data source to get the existing SSM document
data "aws_ssm_document" "webadaptor_config" {
  name            = "arcgis-webadaptor-11-5-configure"  # Your existing SSM document name
  document_format = "YAML"
}

# Data source to find Primary Web Adaptor instances by tags
data "aws_instances" "primary_webadaptor" {
  filter {
    name   = "tag:Name"
    values = [var.webadaptername]
  }

  filter {
    name   = "tag:WebAdaptorRole"
    values = ["Primary"]
  }

  filter {
    name   = "tag:SoftwareComponent"
    values = ["arcgiswebadaptor"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
  
  # Ensure instances exist before trying to trigger
  depends_on = [
    module.webadaptor-ec2,
    aws_iam_role_policy.terraform_ssm_permissions # Wait for IAM permission
  ]
}



# Trigger SSM on Primary Web Adaptor after stack is complete
resource "null_resource" "trigger_primary_webadaptor_config" {

  # Ensure this runs after all critical resources are created
  depends_on = [
    module.webadaptor-ec2,                # Web Adaptor EC2 instance
    aws_iam_role_policy.terraform_ssm_permissions,  # Wait for IAM permissions
    null_resource.trigger_primary_portal_config,        # Portal must be configured first
    null_resource.trigger_primary_ent_arcgisserver_config,    # ENT Server must be configured first
    null_resource.trigger_primary_hosted_arcgisserver_config, # Hosted Server must be configured first
  ]

  # Trigger on resource changes
  triggers = {
    instance_ids = join(",", data.aws_instances.primary_webadaptor.ids)
  }

  provisioner "local-exec" {
    command = <<-EOT
      for instance_id in ${join(" ", data.aws_instances.primary_webadaptor.ids)}; do
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
        --document-name "${data.aws_ssm_document.webadaptor_config.name}" \
        --instance-ids ${join(" ", data.aws_instances.primary_webadaptor.ids)} \
        --parameters '{
          "TomcatHome": ["${var.tomcat_home}"],
          "WAWarFile": ["${var.wa_war_file}"],
          "ArcGISVersion": ["${var.arcgis_version}"],
          "PrivateDNSName":["${module.webadaptor-ec2.private_dns}"],
          "InstanceID":["${module.webadaptor-ec2.id}"],
          "WebAdaptorConfig": ["[{\"name\":\"${var.portal_webadaptor_name}\",\"dnsName\":\"${module.portal-ec2-primary.private_dns}\",\"username\":\"${var.portal_admin_user}\",\"password\":\"${random_password.portal_admin_password.result}\"},{\"name\":\"${var.server_webadaptor_name_ent}\",\"dnsName\":\"${module.arcgis-server-ec2-ent-primary.private_dns}\",\"username\":\"${var.server_admin_user}\",\"password\":\"${random_password.server_admin_password.result}\"},{\"name\":\"${var.server_webadaptor_name_hosted}\",\"dnsName\":\"${module.hosted-server-ec2.private_dns}\",\"username\":\"${var.server_admin_user}\",\"password\":\"${random_password.server_admin_password.result}\"}]"]
        }' \
        --comment "Terraform-triggered Primary WebAdaptor configuration"
    EOT

    interpreter = ["bash", "-c"]
  }
}

