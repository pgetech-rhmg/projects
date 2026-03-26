def lambda_handler(event, context):
    message = 'hello{} {}!'.format(event['first_name'], event['last_name'])  
    return { 
        'message' : message
    }

  
