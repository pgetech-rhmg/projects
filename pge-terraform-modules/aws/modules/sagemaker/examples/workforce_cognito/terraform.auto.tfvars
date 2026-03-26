# Use this operation to create a workforce. This operation will return an error if a workforce already exists in the AWS Region that you specify. 
# You can only create one workforce in each AWS Region per AWS account.
# provide account_num, region and role accordingly to avoid the error.
account_num = "514712703977"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"

name  = "test-workforce-cognito"
cidrs = ["10.0.0.0/24"]