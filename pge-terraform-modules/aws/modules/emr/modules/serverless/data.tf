data "aws_emr_release_labels" "this" {
    
  filters {
    prefix = var.release_label_prefix
  }
}