run "glue_classifier" {
  command = apply

  module {
    source = "./examples/glue_classifier"
  }
}

variables {
  aws_region  = "us-west-2"
  account_num = "056672152820"
  aws_role    = "CloudAdmin"
  name        = "Test-3"
  csv_classifier = [{
    allow_single_column    = false
    contains_header        = "ABSENT"
    delimiter              = ","
    disable_value_trimming = false
    header                 = ["example1", "example2"]
    quote_symbol           = "'"
  }]
}
