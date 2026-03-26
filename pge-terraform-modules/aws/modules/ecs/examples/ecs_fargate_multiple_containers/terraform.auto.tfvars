account_num = "750713712981"
aws_region  = "us-west-2"
aws_role    = "CloudAdmin"
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

#ECS_Fargate
cluster_name = "ecs-fargate-fb1-oxdi"
cpu          = 1024 # need to pass as per application requiremnts
memory       = 2048
#ECS Container Definition
container_name            = "springapp-container"
container_image           = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest" # to pull image from jfog need to follow: first_path_of_repository_url.(dot)jforg base url/artifact_name:version"
fluentbit_container_name  = "custom_fluentbit_logrouter"
fluentbit_container_image = "750713712981.dkr.ecr.us-west-2.amazonaws.com/fluentbit:custom"

#Container Image registry
docker_registry = "JFROG"


# fluentbit_container_image = "514712703977.dkr.ecr.us-west-2.amazonaws.com/fluentbit-ecs-fargate:custom"
container_cpu    = 512 # to pull image from ecr need to follow:  tag_the_image and push to ecr
container_memory = 2048
port_mappings_for_fluentbit = [{
  containerPort = 24224
  hostPort      = 24224
  protocol      = "tcp"
}]
port_mappings = [{
  containerPort = 8081
  hostPort      = 8081
  protocol      = "tcp"
}] # port_mappings need to up updated as per the application port
#ECS service
desired_count = 2 # As per task requirement , you may add 3 or 5 or 7 up to user
load_balancer = [{
  container_name = "springapp-container"
  container_port = 8081
}]
http_port                = 80
https_port               = 443
sample_application_port1 = 8081
#ALB variable
lb_listener_http = [{
  port              = 8081
  protocol          = "HTTP"
  type              = "forward"
  target_group_name = "ecs-fargate-target-blue-b"
  },
  {
    port              = 8082
    protocol          = "HTTP"
    type              = "forward"
    target_group_name = "ecs-fargate-target-green-g"
}]
lb_listener_https = [{
  port     = 443
  protocol = "HTTPS"
  # certificate_arn = "arn:aws:acm:us-west-2:514712703977:certificate/540ab475-1c2e-49be-873c-1d676f282dd8"
  certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/4e1e9dc7-2f17-435f-a95e-804b8d863569"
  target_group_name = "ecs-fargate-target-blue-b"
  type              = "forward"
  },
  {
    port     = 444
    protocol = "HTTPS"
    # certificate_arn = "arn:aws:acm:us-west-2:514712703977:certificate/540ab475-1c2e-49be-873c-1d676f282dd8"
    certificate_arn   = "arn:aws:acm:us-west-2:750713712981:certificate/4e1e9dc7-2f17-435f-a95e-804b8d863569"
    target_group_name = "ecs-fargate-target-green-g"
    type              = "forward"
}]
certificate_arn = [{
  lb_listener_https_port = 443
  # certificate_arn        = "arn:aws:acm:us-west-2:514712703977:certificate/540ab475-1c2e-49be-873c-1d676f282dd8"
  certificate_arn = "arn:aws:acm:us-west-2:750713712981:certificate/4e1e9dc7-2f17-435f-a95e-804b8d863569"
}]

lb_target_group_name           = "ecs-fargate-target-blue-b"
lb_target_group_name2          = "ecs-fargate-target-green-g"
target_group_port              = 8081
target_group_port1             = 8082
log_group_name_prefix          = "my-app-ecs-fargate-petclinic"
sns_topic_cloudwatch_alarm_arn = "arn:aws:sns:us-west-2:514712703977:eks-alarm"


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

wiz_registry_credentials = "wiz_registry_credentials"

jfrog_password = "jfrog/credentials"