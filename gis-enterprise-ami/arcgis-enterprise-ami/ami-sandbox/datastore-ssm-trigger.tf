# Trigger existing SSM document after Terraform stack completion

# Data source to get the existing SSM document
data "aws_ssm_document" "arcgisdatastore_config" {
  name            = "arcgis-datastore-11-5-configure"  # Your existing SSM document name
  document_format = "YAML"
}

# Data source to find Primary Datastore instances by tags
data "aws_instances" "primary_datastore" {
  filter {
    name   = "tag:Name"
    values = [var.datastoremachinename]
  }

  filter {
    name   = "tag:DatastoreRole"
    values = ["Primary"]
  }

  filter {
    name   = "tag:SoftwareComponent"
    values = ["arcgisdatastore"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  # Ensure instances exist before trying to trigger
  depends_on = [
    module.datastore-ec2,
    aws_iam_role_policy.terraform_ssm_permissions  # Wait for IAM permissions
  ]
}

# Trigger SSM on Primary Datastore after stack is complete
resource "null_resource" "trigger_primary_datastore_config" {

  # Ensure this runs after all critical resources are created
  depends_on = [
    module.datastore-ec2,        # Datastore EC2 instance
    aws_iam_role_policy.terraform_ssm_permissions  # Wait for IAM permissions
  ]

  # Trigger on resource changes
  triggers = {
    instance_ids      = join(",", data.aws_instances.primary_datastore.ids)
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 60
      for instance_id in ${join(" ", data.aws_instances.primary_datastore.ids)}; do
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
        --document-name "${data.aws_ssm_document.arcgisdatastore_config.name}" \
        --instance-ids ${join(" ", data.aws_instances.primary_datastore.ids)} \
        --parameters '{
          "ServerAdminUser": ["${var.server_admin_user}"],
          "ServerAdminPassword": ["${random_password.server_admin_password.result}"],
          "DatastoreRole":["Primary"],
          "InstanceId": ["${module.datastore-ec2.id}"],
          "InstanceIp": ["${module.datastore-ec2.private_ip}"],
          "HostedArcGISServerDNSName": ["${module.hosted-server-ec2.private_dns}"],
          "PrimaryDataStoreDNSName": ["${module.datastore-ec2.private_dns}"],
          "PrivateIPDNSName": ["${module.datastore-ec2.private_dns}"],
          "Stores": ["${var.stores}"]
        }' \
        --comment "Terraform-triggered Primary Datastore configuration"
    EOT

    interpreter = ["bash", "-c"]
  }
}

