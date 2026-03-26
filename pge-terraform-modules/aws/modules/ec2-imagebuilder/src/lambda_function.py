import json
from platform import platform
import boto3
import botocore
import email
from botocore.exceptions import ClientError
import os

sns = boto3.client('sns')
ssm = boto3.client('ssm')
ec2_client = boto3.client('ec2')

AMI_ID_PARAM = os.environ['AMI_ID_PARAM']
BETA_AMI_ID_PARAM = os.environ['BETA_AMI_ID_PARAM']
AMI_STATUS_PARAM = os.environ['AMI_STATUS_PARAM']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']
AWS_REGION    = os.environ['AWS_REGION']
SSM_DOCUMENT_NAME_NONPROD = os.environ['SSM_DOCUMENT_NAME_NONPROD']
SSM_DOCUMENT_NAME_PROD = os.environ['SSM_DOCUMENT_NAME_PROD']
ACCOUNT_IDS = os.environ['ACCOUNT_IDS']  # Account Id's as comma separated string
if ACCOUNT_IDS.strip() == "":
    ACCOUNT_IDS = []
else:
    ACCOUNT_IDS = ACCOUNT_IDS.split(",")  
#ACCOUNT_IDS = ACCOUNT_IDS.split(",")    # List of Account Id's
RECEIPIENTS  = os.environ['RECEIPIENTS']  # RECEIPIENTS as comma separated string
RECEIPIENTS  = RECEIPIENTS.split(",")    # List of RECEIPIENTS
SENDER = os.environ['SENDER']
ENVIRONMENT = os.environ['ENVIRONMENT']
env = ""
if ENVIRONMENT.lower() == "prod":
    env = 'Prod'
    SSM_DOCUMENT_NAME = SSM_DOCUMENT_NAME_PROD
else:
    env = 'Non-Prod'
    SSM_DOCUMENT_NAME = SSM_DOCUMENT_NAME_NONPROD

def email_notification_prod(ami_id):
    ec2_client = boto3.client('ec2')
    response = ec2_client.describe_images( ImageIds = [ ami_id ] )
    ami_name = response['Images'][0]['Name']
    SUBJECT = f"New PGE Amazon Golden AMI   {ami_id } is released for {env}"   #update
    CHARSET = "UTF-8"
    BODY_TEXT = "Test email"
    BODY_HTML = """<html>
        <body>
        <title></title>
        <p>Cloud COE have released a newer version of PGE Amazon.  Golden AMI to all PGE {env} AWS accounts. Newly released AMI Id is accessible via AWS Parameter Store</p>
        <ul>
            <li> AMI ID : <strong><big> {ami_id:} </big></strong></li>
        </ul>
        <p> Please use this latest AMI to launch EC2 in your {env} AWS accounts and validate.</p>

        <p> Click here for the list of CVE reported in this AMI &nbsp; &nbsp; <a href="https://wiki.comp.pge.com/display/CCE/AMI+Release+and+CVE+list">CVE List</a></p>
        
        <p>Thanks,</p>

        <p>Cloud COE Engineering Team</p>

        <p>Reach us via email or Teams channel</p>

        <hr />
        </body>
        </html>
            """.format(ami_id=str(ami_id),env=env)
    ses_client = boto3.client('ses',region_name=AWS_REGION)
    try:
        #Provide the contents of the email.
        response = ses_client.send_email(
                Destination={
                    'ToAddresses': RECEIPIENTS
                },
                Message={
                    'Body': {
                        'Html': {
                            'Charset': CHARSET,
                            'Data': BODY_HTML,
                        },
                        'Text': {
                            'Charset': CHARSET,
                            'Data': BODY_TEXT,
                        },
                    },
                    'Subject': {
                        'Charset': CHARSET,
                        'Data': SUBJECT,
                    },
                },
                Source = SENDER
                # If you are not using a configuration set, comment or delete the
                # following line
                #ConfigurationSetName=CONFIGURATION_SET,
            )
        # Display an error if something goes wrong.	
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])

def modify_ami_attributes(ami_id):
    """
    Share an AMI with another AWS account.

    :param ami_id: The id of the AMI you want to share.
    :param account_id: The AWS account id to share the AMI with.
    """

    # Initiate a boto3 EC2 client
    ec2_client = boto3.client('ec2')

    try:
        # Modify image attribute to share with another AWS account
        if ACCOUNT_IDS: 
            response = ec2_client.modify_image_attribute(
                ImageId = ami_id,
                Attribute = 'launchPermission',  # We are modifying the launch permission
                OperationType = 'add',
                UserIds = ACCOUNT_IDS            # The list of account Ids to share with
            )
            print(f"AMI {ami_id} shared successfully with account {ACCOUNT_IDS}.")
            return response
        else:
            print("No Account ID was provided") 
    except ClientError as e:
        print(f"Error sharing AMI: {e}")
        return None
    
def lambda_handler(event, context):
    print(event)

    sns_message = json.loads(event['Records'][0]['Sns']['Message'])
    print(sns_message)
    message_json = (sns_message)

    ami_id = sns_message.get("outputResources", {}).get("amis", [{}])[0].get('image', 'AMI ID not found')
    ami_status = sns_message.get("state",{}).get("status","UNKNOWN")
    notification_message = f"AMI Creation Notification:\nAMI ID: {ami_id}\nStatus: {ami_status}"


    ssm.put_parameter(
        Name = AMI_ID_PARAM,
        Value = ami_id,
        Type = "String",
        Overwrite = True
    )
    ssm.put_parameter(
        Name = BETA_AMI_ID_PARAM,
        Value = ami_id,
        Type = "String",
        Overwrite = True
    )
    ssm.put_parameter(
        Name = AMI_STATUS_PARAM,
        Value = ami_status,
        Type = "String",
        Overwrite = True
    )

    # ami_id_stored = ssm.get_parameter(Name=AMI_ID_PARAM)['Parameter']['Value']
    # ami_status_stored = ssm.get_parameter(Name=AMI_STATUS_PARAM)['Parameter']['Value']

    notification_message = f"""
        AMI Creation Notification:
        AMI ID: {ami_id}
        Status: {ami_status}
        """

    sns.publish(
        TopicArn = SNS_TOPIC_ARN,
        Message = notification_message,
        Subject = "AMI Build Notification"
    )
    
    modify_ami_attributes(ami_id)
    ssm.start_automation_execution(DocumentName=SSM_DOCUMENT_NAME)

    email_notification_prod(ami_id)
    
    return
    

