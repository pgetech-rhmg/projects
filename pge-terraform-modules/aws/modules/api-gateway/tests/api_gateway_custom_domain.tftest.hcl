        run "api_gateway_custom_domain" {
          command = apply
                            
          module {
            source = "./examples/api_gateway_custom_domain"
          }
        }
        
        variables {
        aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
account_num = "750713712981"
AppID       = "1001" 
Environment = "Dev"  
DataClassification = "Internal"                                       
CRIS               = "Low"                                            
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] 
Owner              = ["abc1", "def2", "ghi3"]                         
Compliance         = ["None"]
Order              = 8115205                                           
api_id = "gfgmy1yvlc"
api_type = "Internal"
sub_domain_name = "nonprod"
api_stage = "dev"
        }
