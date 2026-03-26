resource "aws_security_group" "db_security_group" {
  name        = "${var.prefix}-neptune-db-secgrp-${lower(var.suffix)}"
  description = "Allow Neptune Inbound Traffic"
  vpc_id      = data.aws_vpc.mrad_vpc.id

  egress {
    description = "outbound ALLOW_ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  ingress {
    description     = "TO port 8182 FROM CodeBuild security group"
    from_port       = var.neptune_db_cluster_port
    to_port         = var.neptune_db_cluster_port
    protocol        = "tcp"
    security_groups = [data.aws_security_group.lambda_sgs.id]
  }

  ingress {
    description     = "TO port 8182 FROM poller_service"
    from_port       = var.neptune_db_cluster_port
    to_port         = var.neptune_db_cluster_port
    protocol        = "tcp"
    security_groups = [aws_security_group.poller_service.id]
  }

  ingress {
    description = "TO port 8182 FROM VPN CIDR"
    from_port   = var.neptune_db_cluster_port
    to_port     = var.neptune_db_cluster_port
    protocol    = "tcp"
    cidr_blocks = ["172.22.0.0/16"]
  }

  ingress {
    description = "TO port 8182 FROM NLBs"
    from_port   = var.neptune_db_cluster_port
    to_port     = var.neptune_db_cluster_port
    protocol    = "tcp"
    cidr_blocks = [
      data.aws_subnet.mrad1.cidr_block,
      data.aws_subnet.mrad2.cidr_block,
      data.aws_subnet.mrad3.cidr_block
    ]
  }


  tags = var.tags
}

resource "aws_security_group" "poller_service" {
  name        = "${var.prefix}-graph-poller-${lower(var.suffix)}"
  description = "Allow outbound traffic"
  vpc_id      = data.aws_vpc.mrad_vpc.id

  egress {
    description = "outbound ALLOW_ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  tags = var.tags
}

resource "aws_security_group" "consumer_service" {
  name        = "${var.prefix}-graph-consumer-${lower(var.suffix)}"
  description = "Allow outbound traffic"
  vpc_id      = data.aws_vpc.mrad_vpc.id

  egress {
    description = "outbound ALLOW_ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  tags = var.tags
}
