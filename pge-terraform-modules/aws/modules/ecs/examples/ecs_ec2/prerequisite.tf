/*
# Here we are discussing how ECS_EC2_Fluentbit will run in different Acount and Which parameter 

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

with different account user should have pass proper subnet id and subnet cidr (You can get the error due to shortage of IP)

4. Need to update alb ingress value and the value from parameter store and the name convention would be 

   /vpc/securitygroup/inbound/pgecidr1

   /vpc/securitygroup/inbound/pgecidr2

   /vpc/securitygroup/inbound/pgecidr3

. Need to pass minimum parameter like CLuster name

Tag Values (Need to Update below parameters)
     I .     Cluster Name (Name has to be unique)
    II .     Container Image
   III .     Load Balancer 
    IV .     Awslogs_group
     V .     Port_mappings (based on application)
    VI .     Container Name
   VII .     Certificate ARN
  VIII .     Load Balancer Target Groups Name (Name has to be unique)
    IX .     Target Group Port (If needed)
    X  .     ECS Capacity Provider Name (Has to be unique)
 
Detecting / ensuring 'uniqueness' of values - either across a resource type, an entire account, or the globe

7. All the value set in variables as a default.

8. Fluentbit Container should not be open on ECS security Group 

9. The log bucket is created (account number is 514712703977) in s3 and the name is "firelens-fluentbit". You can go s3 and  search for this name "firelens-fluentbit". under this name user will get all the logs.
Bucket should be created in this account before the code run and need to push the fluentbit custom image in ECR or any artifactory.

In the other account 750713712981 the bucket name is firelens-fluentbit-sukw and cloud watch name is "firelens-container"


*/