resource "aws_ecs_cluster" "neptune_service_ecs_cluster" {
  name = "${var.prefix}-neptune-cluster-${lower(var.suffix)}"
  tags = var.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
