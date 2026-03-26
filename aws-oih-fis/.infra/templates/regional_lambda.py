import json


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "status": "ACCESSIBLE",
                "message": "Regional Lambda (no VPC) - not affected by subnet disruption",
                "isolation_test": "CONTROL",
            },
            indent=2,
        ),
    }
