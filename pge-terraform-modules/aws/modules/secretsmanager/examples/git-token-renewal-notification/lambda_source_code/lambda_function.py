import os
import json
import boto3
from datetime import date, datetime, timedelta, timezone

#reading environment variables
git_secret_id = os.environ['git_secretsmanager_name']
sns_topic_arn = os.environ['sns_topic_arn']
num_days = 83

def lambda_handler(event, context):

    #get current sonar token from secrets manager
    secretsmanager_client = boto3.client('secretsmanager')
    get_secret_value_response = secretsmanager_client.get_secret_value(SecretId=git_secret_id)
    last_updated_date = get_secret_value_response['CreatedDate']

    print(f"last rotated date is: {last_updated_date}")

    today = datetime.now(timezone.utc)
    days_since_last_updated = (today - last_updated_date).days

    #check if the secret was modified more than num_days ago
    if days_since_last_updated >= num_days:
        sns_client = boto3.client('sns')

        message = f"GitHub Secrets Manager Secret '{git_secret_id}' hasn't been updated in {days_since_last_updated} days. Regenerate new GitHub PAT with Expiration 90 days and update secrets manager before 90 days"
        subject = f"GitHub Secrets Manager secret '{git_secret_id}' hasn't been updated in {days_since_last_updated} days"
        response = sns_client.publish(
           TopicArn=sns_topic_arn,
           Message=message,
           Subject=subject
        )
        print("SNS messge sent: {}".format(response))
    return
