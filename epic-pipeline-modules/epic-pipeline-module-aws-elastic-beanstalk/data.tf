############################################
# Data
############################################

data "aws_elastic_beanstalk_solution_stack" "type" {
  most_recent = true
  name_regex  = var.solution_stack
}
