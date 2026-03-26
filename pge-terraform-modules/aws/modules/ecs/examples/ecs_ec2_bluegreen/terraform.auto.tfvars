account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
#aws_role    = "TFCBProvisioningRole"
aws_r53_role       = "CloudAdmin"
account_num_r53    = "514712703977"
custom_domain_name = "oxdi-test-ecs-petclinic-bg-new.nonprod.pge.com"

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

parameter_subnet_id1_name = "/vpc/2/privatesubnet1/id"
parameter_subnet_id2_name = "/vpc/2/privatesubnet3/id"

#JFROG secret credentials
jfrog_credentials = "jfrog/credentials"

#ecs_ec2
cluster_name = "ecs-ec2-bg-java-cluster-oxdi"

#ECS task definition
cpu     = 256
memory  = 1048
volumes = []

#Container Image registry
docker_registry = "JFROG"

#ECS container definition
container_name   = "springapp-container"
container_image  = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest" # Need to make sure the ECR repository or JFROG image to be created before running ECS cluster. If not present, the service and tasks will not be coming up actively running.
container_cpu    = 256
container_memory = 1048

entrypoint = null  ####please set to null if you don't want to override the default entrypoint, other wise set to a list of strings based on the requirement of the image

port_mappings = [
  {
    containerPort = 8081
    hostPort      = 8081
    protocol      = "tcp"
  }
]




#ECS service
service_name           = "springapp-oxdi-test-new"
deployment_type        = "CODE_DEPLOY"
deployment_config_name = "CodeDeployDefault.ECSAllAtOnce" # CodeDeployDefault.ECSCanary10Percent5Minutes or CodeDeployDefault.ECSCanary10Percent15Minutes for the canary deployment
desired_count          = 2
load_balancer = [{
  container_name = "springapp-container"
  container_port = 8081
}]

#ECS service Daemon

http_port                = 80
https_port               = 443
sample_application_port1 = 8081

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

https_protocol = "HTTPS"
https_type     = "forward"
https_port1    = 444

lb_target_group_name      = "ecs-ec2-tg-oxdi-test-wiz"
lb_target_group_name_test = "ecs-ec2-tg-aicg-oxdi-test-wiz"

target_group_port      = 443
target_group_port_test = 444
target_group_protocol  = "HTTP"

#ASG variables
launch_template_name = "oxdi-test-wiz"
asg_max_size         = 3
asg_min_size         = 2
asg_desired_capacity = 2
instance_type        = "t3.large"
scaling_adjustment   = 3

