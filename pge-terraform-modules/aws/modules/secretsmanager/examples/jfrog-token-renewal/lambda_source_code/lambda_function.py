import os
import json
import requests
import boto3
from datetime import date, datetime, timedelta
import urllib.parse

#reading environment variables

jfrog_secret_id = os.environ['jfrog_secretsmanager_name']
jfrog_url = os.environ['jfrog_host']
sns_topic_arn = os.environ['sns_topic_arn']
user_name = os.environ['jfrog_user_name']

def lambda_handler(event, context):

    #get current access token and refresh token from secrets manager
    secretsmanager_client = boto3.client('secretsmanager')
    get_secret_value_response = secretsmanager_client.get_secret_value(SecretId=jfrog_secret_id)

    secret_response = get_secret_value_response['SecretString']
    secret_values = json.loads(secret_response)

    current_refresh_token = secret_values['refresh_token']
    current_access_token = secret_values['access_token']


    #formatting jfrog url for renewing token
    url = f"{jfrog_url}/access/api/v1/tokens"

    print(f"formatted url to generate new token is: {url}")

    headers = {'Content-type': 'application/x-www-form-urlencoded', 'Authorization': 'Bearer ' + current_access_token}
    data = {
         'grant_type': 'refresh_token',
         'refresh_token': current_refresh_token,
         'expires_in': 7776000 #token expiration time in seconds set to 90 days
    }

    #generate new token with an expiration to 90 days using access token and refresh token
    response = requests.post(url, headers=headers, data=data)


    if response.status_code == 200:
        response_json = json.loads(response.content)
        access_token_renewed = response_json['access_token']
        refresh_token_renewed = response_json['refresh_token']

        #upload new token to secrets manager
        try:
          secret_value = {"access_token": access_token_renewed, "refresh_token": refresh_token_renewed, "user_name": user_name}
          put_secret_value_reponse = secretsmanager_client.put_secret_value(SecretId=jfrog_secret_id, SecretString=json.dumps(secret_value))


        except Exception as e:
            raise Exception(f'Failed to store token in AWS Secrets Manager: {e}')

        if 'VersionId' in put_secret_value_reponse:
            message = f"Jfrog Secrets Manager Secret '{jfrog_secret_id}' has been renewed and stored new token into secrets manager"
            print("succesfully stored renewed token to secrets manager, ready to send sns message")
            # return put_secret_value_reponse['VersionId']
        else:
            #raise Exception('Failed to store token in AWS Secrets Manager: {e}')
            message = f"Jfrog Secrets Manager Secret '{jfrog_secret_id}' has been renewed but failed to store token into secrets manager, check logs for more details."

    else:
        status_code = response.status_code
        message = f"Failed to renew jfrog access_token, API call faild with status: {status_code}"

        #raise Exception('API call faild with status {}'.format(response.status_code))

    #publish SNS success message
    sns_client = boto3.client('sns')

    print(f"message that's going to be published is: {message}")
    sns_response = sns_client.publish(
       TopicArn=sns_topic_arn,
       Message=message
    )
    print("SNS messge sent: {}".format(sns_response))