account_num        = "750713712981"
aws_region         = "us-west-2"
aws_role           = "CloudAdmin"
aws_r53_role       = "CloudAdmin"
account_num_r53    = "514712703977"
custom_domain_name = "oxdi.ecs-far-bg.nonprod.pge.com"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, Test, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits

#aws_ssm_parameter          
parameter_subnet_id1_name = "/vpc/2/privatesubnet1/id"
parameter_subnet_id2_name = "/vpc/2/privatesubnet3/id"

#JFROG secret credentials
jfrog_credentials = "jfrog/credentials"


#ECS_Fargate
cluster_name = "ecs-fargate-bg-python-cluster-oxdi"

#ECS task definition
cpu    = 512
memory = 2048

#Container Image registry
docker_registry = "JFROG"

#ECS Container Definition
container_name   = "springapp-container"
container_image  = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest" # Need to make sure the ECR repository or JFROG image to be created before running ECS cluster. If not present, the service and tasks will not be coming up actively running.
container_cpu    = 512
container_memory = 2048
port_mappings = [
  {
    containerPort = 8081
    hostPort      = 8081
    protocol      = "tcp"
  }
]

#ECS service
service_name            = "ecs-fargate-bg-service-aicg"
desired_count           = 2
ecs_service_launch_type = "FARGATE"
deployment_type         = "CODE_DEPLOY"
deployment_config_name  = "CodeDeployDefault.ECSAllAtOnce" # CodeDeployDefault.ECSCanary10Percent5Minutes or CodeDeployDefault.ECSCanary10Percent15Minutes for the canary deployment
load_balancer = [{
  container_name = "springapp-container"
  container_port = 8081
}]

ecs_cidr_ingress_rules = [{
  from             = 80,
  to               = 80,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.232.128/25"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
  },
  {
    from             = 443,
    to               = 443,
    protocol         = "tcp",
    cidr_blocks      = ["10.91.129.0/24"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  },
  {
    from             = 8081,
    to               = 8081,
    protocol         = "tcp",
    cidr_blocks      = ["10.91.129.0/24"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules for port 8081 - 1"
  },
  {
    from             = 8081,
    to               = 8081,
    protocol         = "tcp",
    cidr_blocks      = ["10.91.128.0/24"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules for port 8081 - 2"
}]
ecs_cidr_egress_rules = [{
  from             = 80,
  to               = 80,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.232.128/25"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
  },
  {
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
}]

#ALB variable
lb_listener_http = [
  {
    port     = 80
    protocol = "HTTP"
    type     = "redirect"
    redirect = {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  },
  {
    port     = 81
    protocol = "HTTP"
    type     = "redirect"
    redirect = {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
]
https_port           = 443
https_protocol       = "HTTPS"
https_type           = "forward"
lb_target_group_name = "ecs-fe-tgf-py-oxdi"
https_port1          = 444

lb_target_group_name_test = "ecs-fe-tgf-py-oxdi-test"
target_group_target_type  = "ip"
target_group_port         = 443
target_group_port_test    = 444
target_group_protocol     = "HTTP"


alb_cidr_ingress_rules = [{
  from             = 443,
  to               = 443,
  protocol         = "tcp",
  cidr_blocks      = ["10.91.0.0/16", "10.90.0.0/16", "192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE Ingress rules"
  },
  {
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = ["10.91.0.0/16", "10.90.0.0/16", "192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
  }
]
alb_cidr_egress_rules = [{
  from             = 80,
  to               = 80,
  protocol         = "tcp",
  cidr_blocks      = ["10.90.232.0/25", "10.90.232.128/25"]
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
  description      = "CCOE egress rules"
  },
  {
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
}]

## ECS cluster Autoscalling

create_autoscaling = false # Whether to create autoscaling


use_target_tracking_scaling = true # Whether to use target tracking scaling policy or step scaling policy, value has to be false to use step scalling

step_scaling_policy_name = "" # Name of the step scaling policy if you are creating step scaling policy
step_scaling_policy_configuration = {
  adjustment_type         = "ChangeInCapacity" #Allowed values are ChangeInCapacity, PercentChangeInCapacity, ExactCapacity
  cooldown                = 300
  metric_aggregation_type = "Average" #Allowed values are Minimum, Maximum, Average
  step_adjustment = [{
    metric_interval_lower_bound = 2.0
    metric_interval_upper_bound = 3.0
    scaling_adjustment          = 1
    }
  ]
}


target_tracking_scaling_policy_name = "Target-scaling-test" #name of the target tracking scaling policy if you are creating target tracking scaling policy
target_tracking_scaling_policy_configuration = {
  target_value       = 50.0
  scale_in_cooldown  = 300
  scale_out_cooldown = 300
  disable_scale_in   = false
  predefined_metric_specification = [
    {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization" # Predefined metric type for target tracking scaling policy can either be ECSServiceAverageCPUUtilization, ECSServiceAverageMemoryUtilization, ALBRequestCountPerTarget
    }
  ]
}

runtime_platform = {
  "cpuArchitecture"       = "X86_64"
  "operatingSystemFamily" = "LINUX"
}

###   Important Note for Wiz Runtime Sensor Integration with ECS Fargate - https://docs.wiz.io/docs/serverless-sensor-install-embedded
##### To enable Wiz Runtime Sensor in your ECS Fargate container, you need to modify the ENTRYPOINT of your container definition.
##### Adjust the ENTRYPOINT to initiate the Runtime Sensor, which in turn replaces your original entry point. 
##### Ensure you concatenate both the original ENTRYPOINT and CMD values. 
##### This ensures the Sensor is activated and protects your application upon container startup: See example below.

#### ENTRYPOINT ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "ORIGINAL-ENTRYPOINT", "ORIGINAL-ARG1", "ORIGINAL-ARG2"]

entrypoint = ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "java", "-jar", "/spring-petclinic/spring-petclinic.jar", "--server.port=8081"]

command = null


wiz_secret_credential = "shared-wiz-access"



