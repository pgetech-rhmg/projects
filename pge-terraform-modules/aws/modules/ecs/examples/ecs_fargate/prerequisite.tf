/*

Here we are creating new example of ecs_fargate_twistlock. In ecs, twistlock is securing the task definition and created a new protected task definition where it added a new container like twistlock defender on top of the application container and passing few more parameters like entrypoint, environment, volumes.

In ecs fargate we are adding one more container which is TwistlockDefender container and passing through the ecs_task_definition. 
After deploying the TwistlockDefender it is creating a new container which is attached with the application container.
parallely we can see the task definition in Prisma cloud.

Here in Prisma https://itiamping.cloud.pge.com/idp/startSSO.ping?PartnerSpId=https%3A%2F%2Fapp.prismacloud.io%2Fcustomer%2F81dc61c9e4bb1f9a4d52a0ebbcaae2bc
cloud , user need to log in Prisma cloud 
then Naviagte to Compute then Manage -- then Defenders. 
Then user need to find out through the ecs_task definition name then they will see the details component like connectivity, Filesystem, network, process, container network Segmentation, application firewall and cluster with that user can see the status of this component like Enabled or Not Available.

Here I am adding a wiki link where user will see the picture in prisma cloud after adding a TwistlockDefender container in ECS_Faragte.

https://wiki.comp.pge.com/display/CCE/ECS+Fargate+with+Twistlock+Examples


To create this cluster (ECS_Fargate_twistlock) if you get any token error you can reach out to PGE security Team like Tommy Hunt.

Also I am ataching the wiki link where user will get the info to to it manual way. This page is from PGE wiki page.

https://wiki.comp.pge.com/display/CCE/Embed+Defender-Sidecar+into+ECS+on+Fargate+Tasks



# Here we are discussing how ECS_FARGATE_Twistlock will run in different Acount and Which parameter 

1.Need to change the account name

2.Need to add vpc id from parameter store (ssm)

Exp:  /vpc/id

3.Need to update the subnet and cidr block from parameter store (ssm)

EXP: subnet name will be

   /vpc/privatesubnet1/id

   /vpc/privatesubnet2/id

   /vpc/privatesubnet3/id

EXP: cidr block will be from parameter store (ssm)

   /vpc/privatesubnet1/cidr

   /vpc/privatesubnet2/cidr

   /vpc/privatesubnet3/cidr

4. Need to update alb ingress value and the value from parameter store and the name convention would be 

   /vpc/securitygroup/inbound/pgecidr1

   /vpc/securitygroup/inbound/pgecidr2

   /vpc/securitygroup/inbound/pgecidr3

5. Need to store jfrog_credentials in secrets manager and it would  be pass 

   data "aws_secretsmanager_secret" "jfrog_password" {
   name = var.jfrog_password
}

data "aws_secretsmanager_secret_version" "latest_version" {
  secret_id = data.aws_secretsmanager_secret.jfrog_password.id
}

6. Need to pass minimum parameter like CLuster name

Tag Values (Need to Update below parameters)
     I .     Cluster Name (Name has to be unique)
    II .     Container Image
   III .     Load Balancer (line 29 to 32)
    IV .     Awslogs_group
     V .     Port_mappings (based on application)
    VI .     Container Name
   VII .     Certificate ARN
  VIII .     Load Balancer Target Groups Name (Name has to be unique)
    IX .     Target Group Port (If needed)
 
Detecting / ensuring 'uniqueness' of values - either across a resource type, an entire account, or the globe

7. Rest of all the value set in variables as a default.

Before run the code user need to follow the wiki page for ecs_fargate_twistlock


*/