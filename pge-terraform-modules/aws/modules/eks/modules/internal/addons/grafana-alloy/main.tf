# resource "aws_iam_role" "grafana_alloy" {
#   name  = "${var.cluster_name}-grafana-alloy-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "pods.eks.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })

#   tags = var.tags
# }

# # Empty policy - Alloy only needs Kubernetes RBAC permissions
# resource "aws_iam_policy" "grafana_alloy" {
#   name        = "${var.cluster_name}-grafana-alloy-policy"
#   description = "IAM policy for Grafana Alloy Kubernetes monitoring"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = []
#   })

#   tags = var.tags
# }

# resource "aws_iam_role_policy_attachment" "grafana_alloy" {
#   policy_arn = aws_iam_policy.grafana_alloy.arn
#   role       = aws_iam_role.grafana_alloy.name
# }

# resource "aws_eks_pod_identity_association" "grafana_alloy" {
#   cluster_name    = var.cluster_name
#   namespace       = var.namespace
#   service_account = var.service_account
#   role_arn        = aws_iam_role.grafana_alloy.arn

#   tags = var.tags
# }