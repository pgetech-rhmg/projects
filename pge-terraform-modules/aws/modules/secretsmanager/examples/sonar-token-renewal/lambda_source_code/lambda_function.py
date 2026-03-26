import os
import json
import requests
import boto3
from datetime import date, datetime, timedelta
import urllib.parse

#reading environment variables

token_name = os.environ['sonar_token_name_new']
sonar_secret_id = os.environ['sonar_secretsmanager_name']
secret_key = os.environ['secrets_manager_token_keyname']
sonar_url = os.environ['sonar_host']
sns_topic_arn = os.environ['sns_topic_arn']

#adding date to token name
timestamp = datetime.now().strftime('%m-%d-%Y-%H-%M-%S')
sonar_token_name = token_name + "-" + timestamp

def lambda_handler(event, context):

    #get current sonar token from secrets manager
    secretsmanager_client = boto3.client('secretsmanager')
    get_secret_value_response = secretsmanager_client.get_secret_value(SecretId=sonar_secret_id)

    #get secret value based on plaintext or key value pair
    if secret_key:
        auth_token = json.loads(get_secret_value_response['SecretString'])[secret_key]
    else:
        auth_token = get_secret_value_response['SecretString']

    url = f"{sonar_url}/api/user_tokens/generate"
    args = {'name': sonar_token_name,'expirationDate': (datetime.now() + timedelta(days=90)).strftime('%Y-%m-%d')}
    encoded_args = urllib.parse.urlencode(args)

    url = f"{url}?{encoded_args}"

    print(f"formatted url to generate new token is: {url}")

    args = {'name': sonar_token_name,'expirationDate': (datetime.now() + timedelta(days=90)).strftime('%Y-%m-%d')}

    headers = {'Content-type': 'application/json'}

    #generate new token with an expiration to 90 days
    response = requests.post(url, headers=headers, auth=(auth_token, ''))


    if response.status_code == 200:
        response_json = json.loads(response.content)
        sonar_token_renewed = response_json['token']

        #upload new token to secrets manager 
        try:
            if secret_key:
                secret_value = {secret_key: sonar_token_renewed}
                put_secret_value_reponse = secretsmanager_client.put_secret_value(SecretId=sonar_secret_id, SecretString=json.dumps(secret_value))
            else:
                put_secret_value_reponse = secretsmanager_client.put_secret_value(SecretId=sonar_secret_id, SecretString=sonar_token_renewed)

        except Exception as e:
            sns_message = f"SonarQube Secrets Manager Secret '{sonar_secret_id}' has been renewed but failed to store new token into secrets manager"

        if 'VersionId' in put_secret_value_reponse:
            sns_message = f"SonarQube Secrets Manager Secret '{sonar_secret_id}' has been renewed and stored new token into secrets manager"
            print("succesfully stored renewed token to secrets manager")
        else:
            sns_message = f"SonarQube Secrets Manager Secret '{sonar_secret_id}' has been renewed but failed to store token into secrets manager, check logs for more details."


    else:
        status_code = response.status_code
        sns_message = f"Failed to renew SonarQube token, API call faild with status: {status_code}" 

    #publish SNS success message
    sns_client = boto3.client('sns')

    print(f"message that's going to be published is: {sns_message}")
    sns_response = sns_client.publish(
        TopicArn=sns_topic_arn,
        Message=sns_message
    )
    print("SNS messge sent: {}".format(sns_response))