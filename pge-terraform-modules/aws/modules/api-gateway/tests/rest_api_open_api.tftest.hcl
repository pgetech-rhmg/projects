        run "rest_api_open_api" {
          command = apply
                            
          module {
            source = "./examples/rest_api_open_api"
          }
        }
        
        variables {
        account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
AppID       = "1001" 
Environment = "Dev"  
DataClassification = "Internal"                                       
CRIS               = "Low"                                            
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] 
Owner              = ["abc1", "def2", "ghi3"]                         
Compliance         = ["None"]
Order              = 8115205                                           
ssm_parameter_vpc_id     = "/vpc/id"
ssm_parameter_subnet_id1 = "/vpc/2/privatesubnet1/id"
rest_api_name = "rest_api_open_api"
pVpcEndpoint = "vpce-0153835f967c30984"
stage_name                  = "open_api_stage"
stage_cache_cluster_enabled = true
stage_cache_cluster_size    = 0.5
method_settings_method_path = "*/*"
settings_logging_level      = "INFO"
api_key_name = "sample_api_key"
usage_plan_name        = "usage_plan_test"
usage_plan_description = "Provides an API Gateway Usage Plan"
usage_plan_key_type = "API_KEY"
        }
