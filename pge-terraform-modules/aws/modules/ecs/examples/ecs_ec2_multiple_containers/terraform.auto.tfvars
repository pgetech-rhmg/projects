account_num        = "750713712981"
aws_region         = "us-west-2"
aws_role           = "CloudAdmin"
account_num_r53    = "514712703977"
aws_r53_role       = "CloudAdmin"
custom_domain_name = "oxdi.ecs-nodeapp.nonprod.pge.com"

#Tags
AppID       = "1001" #"Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
Environment = "Dev"  #Dev, service-01test01, QA, Prod (only one)
# If DataClassification is Confidential, Restricted, Restricted-BCSI, Confidential-BSCI, Please follow the steps
# Detailed in the wiki page https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
DataClassification = "Internal"                                       #Public, Internal, Confidential, Restricted, Restricted-BCSI, Confidential-BSCI (only one)
CRIS               = "Low"                                            #"Cyber Risk Impact Score High, Medium, Low (only one)"
Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"] #Who to notify for system failure or maintenance. Should be a group or list of email addresses."
Owner              = ["abc1", "def2", "ghi3"]                         #List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg"
Compliance         = ["None"]
Order              = 8115205 #Order must be between 7 and 9 digits

#aws_ssm_parameter                                                 
parameter_golden_ami_name = "/ami/linux/ecs-optimized"

#ecs_ec2
cluster_name  = "ecs-ec2-fb-oxdi"
setting_value = "enabled"

#ECS task definition
memory = 1048

#ECS capacity provider
ecs_capacity_provider_name = "capacity_provider_ecsec2_test"

jfrog_credentials = "jfrog/credentials"

#Container Image registry
docker_registry = "JFROG"


#ECS container definition
container_name           = "springapp-container"
fluentbit_container_name = "custom_fluentbit_logrouter"
container_image          = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest"
# fluentbit_container_image = "514712703977.dkr.ecr.us-west-2.amazonaws.com/fluentbit-ecs-fargate:custom"
fluentbit_container_image = "750713712981.dkr.ecr.us-west-2.amazonaws.com/fluentbit:custom"
container_cpu             = 256
container_memory          = 1048

entrypoint = null  ####please set to null if you don't want to override the default entrypoint, other wise set to a list of strings based on the requirement of the image

#hostPort              = 8081
#logDriver             = "awslogs"
#awslogs_group         = "ecsec2-logsgroup"
#awslogs_stream_prefix = "ecsec2-logsgroup"
port_mappings = [{
  containerPort = 8081
  hostPort      = 8081
  protocol      = "tcp"
}]

fluentbit_port_mappings = [{
  containerPort = 24224
  hostPort      = 24224
  protocol      = "tcp"
}]

#ECS service
desired_count = 2
load_balancer = [{
  container_name = "springapp-container"
  container_port = 8081
}]

http_port                = 80
https_port               = 443
sample_application_port1 = 8081

#IAM role
ecs_iam_aws_service = ["ec2.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
ecs_iam_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", "arn:aws:iam::aws:policy/AmazonECS_FullAccess", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", "arn:aws:iam::aws:policy/AmazonSSMFullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]

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


https_protocol         = "HTTPS"
https_type             = "forward"
lb_target_group_name   = "ecs-ec2-svc-tg"
target_group_port      = 8081
target_group_protocol  = "HTTP"
lb_listener_https_port = 443

#S3 variables
policy = "s3_policy.json"

#Cloudwatch variable
log_group_name_prefix = "ecs_ec2_service"


#ASG variables
launch_template_name = "oxdi-test-new"
asg_max_size         = 4
asg_min_size         = 2
asg_desired_capacity = 3
instance_type        = "m6id.large"
scaling_adjustment   = 4

#Targetgroup variables
port = 8081

sns_topic_cloudwatch_alarm_arn = "arn:aws:sns:us-west-2:514712703977:eks-alarm"

