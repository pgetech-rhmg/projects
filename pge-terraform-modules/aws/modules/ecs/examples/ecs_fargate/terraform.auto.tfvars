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
account_num_r53    = "514712703977"
custom_domain_name = "ecs-fargate-wiz.nonprod.pge.com"

#ECS_Fargate
cluster_name = "ecstwl2-fargate"
cpu          = 1024 # need to pass as per application requiremnts
memory       = 3072
#ECS Container Definition
container_name = "springapp-container"

service_name = "ecstwlsv1"

container_image = "ccoe-cicd-docker-virtual.jfrog.nonprod.pge.com/spring-petclinic:pge-latest" # to pull image from jfog need to follow: first_path_of_repository_url.(dot)jforg base url/artifact_name:version"

container_cpu    = 512 # to pull image from ecr need to follow:  tag_the_image and push to ecr
container_memory = 2048
port_mappings = [{
  containerPort = 8081
  hostPort      = 8081
  protocol      = "tcp"
}] # port_mappings need to up updated as per the application port

###   Important Note for Wiz Runtime Sensor Integration with ECS Fargate - https://docs.wiz.io/docs/serverless-sensor-install-embedded
##### To enable Wiz Runtime Sensor in your ECS Fargate container, you need to modify the ENTRYPOINT of your container definition.
##### Adjust the ENTRYPOINT to initiate the Runtime Sensor, which in turn replaces your original entry point. 
##### Ensure you concatenate both the original ENTRYPOINT and CMD values. 
##### This ensures the Sensor is activated and protects your application upon container startup: See example below.

#### ENTRYPOINT ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "ORIGINAL-ENTRYPOINT", "ORIGINAL-ARG1", "ORIGINAL-ARG2"]

entrypoint = ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "java", "-jar", "/spring-petclinic/spring-petclinic.jar", "--server.port=8081"]

command    = null

#Container Image registry
docker_registry = "JFROG"

runtime_platform = {
  "cpuArchitecture"       = "X86_64"
  "operatingSystemFamily" = "LINUX"
}

#ECS service
desired_count = 1 # As per task requirement , you may add 3 or 5 or 7 up to user
load_balancer = [{
  container_name = "springapp-container"
  container_port = 8081
}]
http_port                = 80
sample_application_port1 = 8081
#ALB variable
lb_listener_http = [{
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
}]

lb_target_group_name = "ecs-fargate-target-blue-D"
target_group_port    = 8081

jfrog_credential = "jfrog/credentials"
https_port       = 443
https_protocol   = "HTTPS"
https_type       = "forward"


wiz_secret_credential = "shared-wiz-access"

