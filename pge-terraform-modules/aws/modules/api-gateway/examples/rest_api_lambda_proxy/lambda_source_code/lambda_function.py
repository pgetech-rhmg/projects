import json

def exception_handler(e):
    # exception to status code mapping goes here...
    status_code = 200
    return {
        'statusCode': status_code,
        'body': json.dumps(str(e))
    }

def lambda_handler(event, context):
    try:
        raise Exception('This is an exception!')
        return {
            'statusCode': 200,
            'body': json.dumps('This is a good request!')
        }
    except Exception as e:
        return exception_handler(e)