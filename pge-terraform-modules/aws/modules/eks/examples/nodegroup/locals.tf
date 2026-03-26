locals {
  eks_managed_node_groups = {
    # Default node group - for admin pods
    admin_nodegroup = {
      use_custom_launch_template = false

      ami_type       = var.ami_type
      instance_types = ["m6i.large"]

      subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]

      min_size      = 1
      max_size      = 5
      desired_size  = 1
      capacity_type = "ON_DEMAND"
      taints = [
        {
          key    = "dedicated"
          value  = "AdminGroup"
          effect = "NO_SCHEDULE"
        }
      ]
      labels = {
        dedicated = "AdminGroup"
      }
    }
    # Node group which is pointed to all three AZs
    launch_template_nodegroup_multi = {
      name                       = "two"
      use_name_prefix            = true
      use_custom_launch_template = true

      subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]

      min_size     = 1
      max_size     = 7
      desired_size = 1

      ami_type                   = var.ami_type
      ami_id                     = var.ami_id
      enable_bootstrap_user_data = true

      cloudinit_pre_nodeadm = [{
        content      = <<-EOT
          ---
          apiVersion: node.eks.aws/v1alpha1
          kind: NodeConfig
          spec:
            kubelet:
              config:
                shutdownGracePeriod: 30s
        EOT
        content_type = "application/node.eks.aws"
      }]

      post_bootstrap_user_data = <<-EOT
        echo "Updating /etc/hosts to include comp.pge.com domain"
        echo "Add comp.pge.com to domain search in /etc/dhcp/dhclient.conf"
        echo 'supersede domain-search "comp.pge.com";' >> /etc/dhcp/dhclient.conf
        echo "Post bootstrap user data script executed"
      EOT 

      capacity_type = "ON_DEMAND"

      instance_types = ["m5.xlarge"]
      taints         = []
      labels         = {}
      update_config = {
        max_unavailable            = 1
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      description = "EKS managed node group example launch template"

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true


      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }


      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }


    }

    # # Node group which is pointed to any single AZ only for a specific use case if applicable
    launch_template_nodegroup = {
      name                       = "one"
      use_name_prefix            = true
      use_custom_launch_template = true

      subnet_ids = [data.aws_ssm_parameter.subnet_id2.value]

      min_size     = 1
      max_size     = 7
      desired_size = 1

      ami_type                   = var.ami_type
      ami_id                     = var.ami_id
      enable_bootstrap_user_data = true
      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative

      cloudinit_pre_nodeadm = [{
        content      = <<-EOT
          ---
          apiVersion: node.eks.aws/v1alpha1
          kind: NodeConfig
          spec:
            kubelet:
              config:
                shutdownGracePeriod: 30s
        EOT
        content_type = "application/node.eks.aws"
      }]

      post_bootstrap_user_data = <<-EOT
        echo "Updating /etc/hosts to include comp.pge.com domain"
        echo "Add comp.pge.com to domain search in /etc/dhcp/dhclient.conf"
        echo 'supersede domain-search "comp.pge.com";' >> /etc/dhcp/dhclient.conf
        echo "Post bootstrap user data script executed"
      EOT 

      capacity_type = "ON_DEMAND"

      instance_types = ["m5.xlarge"]
      taints         = []
      labels         = {}
      update_config = {
        max_unavailable            = 1
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      description = "EKS managed node group example launch template"

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
    }
  }

}