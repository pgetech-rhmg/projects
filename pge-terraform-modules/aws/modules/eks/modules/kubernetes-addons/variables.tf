variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}

#--------custom-role--------------------

variable "custom_identity" {
  description = "Name of IAM role"
  type        = string
  default     = ""
}

variable "create_custom_role" {
  description = "Determines whether to create the custom IAM role"
  type        = bool
  default     = false
}

variable "custom_identity_associations" {
  description = "Map of Pod Identity associations to be created (map of maps)"
  type        = any
  default     = {}
}

variable "custom_identity_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document"
  type        = list(string)
  default     = []
}

variable "custom_identity_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document"
  type        = list(string)
  default     = []
}

variable "custom_identity_additional_policy_arns" {
  description = "ARNs of additional policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "custom_identity_trust_policy_conditions" {
  description = "A list of conditions to add to the role trust policy"
  type        = any
  default     = []
}
variable "create_karpenter_resources" {
  description = "Create karpenter adddon resources, node role , controller role, queue for eks cluster"
  type        = bool
  default     = false
}

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = null
}


#-----------AWS LB Ingress Controller-------------
variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "custom_image_registry_uri" {
  description = "Custom image registry URI map of `{region = dkr.endpoint }`"
  type        = map(string)
  default     = {}
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  type        = string
  default     = ""
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
  default     = ""
}


variable "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

### external DNS
variable "domain_env" {
  description = "[NONPROD/PROD]Environment value to pick respective Domain name of the Route53 hosted zone to use with External DNS."
  type        = string
  default     = "nonprod"
}

variable "attach_external_dns_policy" {
  description = "Determines whether to attach the External DNS IAM policy to the role"
  type        = bool
  default     = false
}

variable "route53_zone_arns" {
  description = "List of Route53 zones ARNs which external-dns will have access to create/manage records"
  type        = list(string)
  default     = []
}

variable "external_dns_policy_name" {
  description = "Custom name of the External DNS IAM policy"
  type        = string
  default     = null
}
#-----------METRIC SERVER-------------
variable "enable_metrics_server" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = false
}

#-----------kube state metrics-------------
variable "enable_kube_state_metrics" {
  description = "Enable kube state metrics add-on"
  type        = bool
  default     = false
}

module "validate-pge-tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"

  tags = var.tags
}
variable "cluster_dimensions" {
  description = "List of metrics to notify. <br>metric_name is the metric name to be notified. <br>comparison_operator is the type of comparison operation. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>Specify an empty map if you do not want to notify Cluster level alerts."
  type = map(object({
    metric_name         = string
    comparison_operator = string
    period              = string
    statistic           = string
    threshold           = string
  }))
  default = {}
}

variable "namespace_dimensions" {
  description = "List of metrics to notify. <br>metric_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the namespace name to be notified. <br>Specify an empty map if you do not want to notify Namespace level alerts."
  type = map(object({
    metric_name         = string
    comparison_operator = string
    period              = string
    statistic           = string
    threshold           = string
    namespace           = string
  }))
  default = {}
}

variable "service_dimensions" {
  description = "List of metrics to notify. <br>metric_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the name of the namespace where the notification target Service operates. <br>Service is the Pod name to be notified. <br>Specify an empty map if you do not want to notify Service level alerts."
  type = map(object({
    metric_name         = string
    comparison_operator = string
    period              = string
    statistic           = string
    threshold           = string
    namespace           = string
    service             = string
  }))
  default = {}
}

variable "pod_dimensions" {
  description = "List of metrics to notify. <br>metric_name is the metric name to be notified. <br>period is the aggregation period (seconds). <br>statistic is the type of statistics. <br>threshold is the threshold. <br>namespace is the name of the namespace where the pod to be notified runs. <br>Pod is the pod name to be notified. <br>Specify an empty map if you do not want to perform Pod-level alert notifications."
  type = map(object({
    metric_name         = string
    comparison_operator = string
    period              = string
    statistic           = string
    threshold           = string
    namespace           = string
    pod                 = string
  }))
  default = {}
}


variable "create_eks_dashboard" {
  description = "eks dashboard true/false"
  type        = bool
  default     = false
}

variable "sns-topic" {
  description = "input email for alarm notification"
  type        = string

}

variable "enable_aws_cloudwatch_metrics" {
  description = "Enable AWS CloudWatch Metrics add-on for Container Insights"
  type        = bool
  default     = false
}

#new approach

variable "cluster_name" {
  type        = string
  description = "The name of your EKS Cluster"
  validation {
    condition     = 20 >= length(var.cluster_name) && length(var.cluster_name) > 0 && can(regex("^[0-9A-Za-z][A-Za-z0-9-_]+$", var.cluster_name))
    error_message = "'cluster_name' should be between 1 and 20 characters, start with alphanumeric character and contain alphanumeric characters, dashes and underscores."
  }
}

variable "create_cluster_autoscaler_resources" {
  description = "Determines whether to create the Cluster Autoscaler IAM role"
  type        = bool
  default     = false
}

variable "create_lb_controller_resources" {
  description = "Determines whether to create the AWS Load Balancer Controller IAM role"
  type        = bool
  default     = true
}

variable "create_loki_resources" {
  description = "Determines whether to create Grafana Loki resources such as S3 buckets and IAM roles"
  type        = bool
  default     = false
}

variable "create_mimir_resources" {
  description = "Determines whether to create Grafana Mimir resources such as S3 buckets and IAM roles"
  type        = bool
  default     = false
}

variable "create_tempo_resources" {
  description = "Determines whether to create Grafana Tempo resources such as S3 buckets and IAM roles"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_cluster_names" {
  description = "List of cluster names to appropriately scope permissions within the Cluster Autoscaler IAM policy"
  type        = list(string)
  default     = []
}

variable "create_ebs_csi_resources" {
  description = "Determines whether to create the ebs csi IAM role"
  type        = bool
  default     = false

}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"

}

variable "attach_aws_ebs_csi_policy" {
  description = "Determines whether to attach the EBS CSI IAM policy to the role"
  type        = bool
  default     = false
}


variable "aws_ebs_csi_policy_name" {
  description = "Custom name of the EBS CSI IAM policy"
  type        = string
  default     = null
}

variable "aws_ebs_csi_kms_arns" {
  description = "KMS key ARNs to allow EBS CSI to manage encrypted volumes"
  type        = list(string)
  default     = []
}

variable "encrypt_ebs_csi" {
  description = "Determines whether to encrypt EBS volumes created by the EBS CSI driver"
  type        = bool
  default     = false
}

### efs csi
variable "create_efs_csi_resources" {
  description = "Determines whether to create the efs csi IAM role"
  type        = bool
  default     = false

}

variable "attach_aws_efs_csi_policy" {
  description = "Determines whether to attach the EFS CSI IAM policy to the role"
  type        = bool
  default     = false
}

variable "aws_efs_csi_policy_name" {
  description = "Custom name of the EFS CSI IAM policy"
  type        = string
  default     = null
}


### external DNS
variable "create_external_dns_resources" {
  description = "Determines whether to create the external dns IAM role"
  type        = bool
  default     = true
}

### external secrets
variable "create_external_secrets_resources" {
  description = "Determines whether to create the external secrets IAM role"
  type        = bool
  default     = true
}

variable "attach_external_secrets_policy" {
  description = "Determines whether to attach the External Secrets policy to the role"
  type        = bool
  default     = false
}

variable "external_secrets_policy_name" {
  description = "Custom name of the External Secrets IAM policy"
  type        = string
  default     = null
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = []
}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = []
}

variable "external_secrets_kms_key_arns" {
  description = "List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = []
}

variable "external_secrets_create_permission" {
  description = "Determines whether External Secrets has permission to create/delete secrets"
  type        = bool
  default     = false
}

# AWS Load Balancer Controller
variable "aws_lb_controller_policy_name" {
  description = "Custom name of the AWS Load Balancer Controller IAM policy"
  type        = string
  default     = null
}

# AWS Load Balancer Controller TargetGroup Binding Only
variable "attach_aws_lb_controller_targetgroup_binding_only_policy" {
  description = "Determines whether to attach the AWS Load Balancer Controller policy for the TargetGroupBinding only"
  type        = bool
  default     = false
}

variable "aws_lb_controller_targetgroup_only_policy_name" {
  description = "Custom name of the AWS Load Balancer Controller IAM policy for the TargetGroupBinding only"
  type        = string
  default     = null
}

variable "aws_lb_controller_targetgroup_arns" {
  description = "List of Target groups ARNs using Load Balancer Controller"
  type        = list(string)
  default     = []
}

# AWS VPC CNI

variable "create_vpc_cni_resources" {
  description = "Determines whether to create VPC CNI IAM Role"
  type        = bool
  default     = false
}
variable "attach_aws_vpc_cni_policy" {
  description = "Determines whether to attach the VPC CNI IAM policy to the role"
  type        = bool
  default     = false
}

variable "aws_vpc_cni_policy_name" {
  description = "Custom name of the VPC CNI IAM policy"
  type        = string
  default     = null
}

variable "aws_vpc_cni_enable_ipv4" {
  description = "Determines whether to enable IPv4 permissions for VPC CNI policy"
  type        = bool
  default     = false
}

#fluentbit

variable "create_aws_for_fluentbit_resources" {

  description = "Determines whether to create aws for fluentbit IAM Role"
  type        = bool
  default     = false

}

variable "attach_aws_for_fluentbit_policy" {
  description = "Determines whether to attach the aws for fluentbit policy to the role"
  type        = bool
  default     = false
}
