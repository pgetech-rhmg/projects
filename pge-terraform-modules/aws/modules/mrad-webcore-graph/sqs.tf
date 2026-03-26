module "graph_sqs" {
  source  = "app.terraform.io/pgetech/sqs/aws"
  version = "0.1.1"

  sqs_name = "${var.prefix}-graph-${lower(var.suffix)}.fifo"
  tags     = var.tags
}
