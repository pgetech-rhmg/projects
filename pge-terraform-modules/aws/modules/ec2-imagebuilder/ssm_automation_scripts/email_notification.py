def email_notification_prod(event, context):
                    import boto3
                    import botocore
                    import email   
                    from botocore.exceptions import ClientError
                    #sns_client = boto3.client('sns')
                    ec2_client = boto3.client('ec2')
                    ami_parameter_store = event['ami_parameter_store']
                    ami_id = event['beta_ami_id']
                    SENDER = event['sender']
                    ENVIRONMENT = event['environment']
                    RECIPIENT = event['recipient'].split(",")
                    env = ""
                    if ENVIRONMENT.lower() == "prod":
                        env = 'Prod'
                    else:
                        env = 'Non-Prod'
                    #
                    if ami_parameter_store.lower().find("window") >= 0:
                        platform = 'Windows'
                    else:
                        platform = 'Linux'
                    #
                    response = ec2_client.describe_images( ImageIds = [ ami_id ] )
                    ami_name = response['Images'][0]['Name']
                    #SENDER = "ccoe-ami-notification@ss.pge.com"
                    #RECIPIENT = ["coe-nonprod-linux-ami-release@pge.com", "AWSDevOpsPractitioners@pge.com"]
                    AWS_REGION = "us-west-2"
                    SUBJECT = f"New PGE Amazon  platform  Golden AMI  {ami_id}  is released for {env}"
                    CHARSET = "UTF-8"
                    BODY_TEXT = "Test email"
                    BODY_HTML = """<html>
                     <body>
                      <title></title>
                      <p>Cloud COE have released a newer version of PGE Amazon {platform:}  Golden AMI to all PGE {env} AWS accounts. Newly released AMI Id is accessible via AWS Parameter Store</p>
                        <ul>
                            <li> AMI ID : <strong><big> {ami_id:} </big></strong></li>
                             <li> AWS Parameter Store :<strong><big>{ami_parameter_store:} </big></strong> </li>
                        </ul>
                      <p> Please use this latest AMI to launch EC2 in your {env} AWS accounts and validate.</p>

                      <p>Thanks,</p>

                      <p>Cloud COE Engineering Team</p>

                      <p>Reach us via email or Teams channel</p>

                      <hr />
                      </body>
                      </html>
                          """.format(platform=str(platform),ami_id=str(ami_id),ami_name=str(ami_name), ami_parameter_store=str(ami_parameter_store), env=env)
                    ses_client = boto3.client('ses',region_name=AWS_REGION)
                    try:
                      #Provide the contents of the email.
                      response = ses_client.send_email(
                              Destination={
                                    'ToAddresses': RECIPIENT
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
                                Source=SENDER
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