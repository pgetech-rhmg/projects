import json
import boto3
import io
import zipfile

s3_client = boto3.client("s3")
codepipeline_client = boto3.client("codepipeline")

def handler(event, context):
    job_id = event["CodePipeline.job"]["id"]
    job_data = event["CodePipeline.job"]["data"]
    
    try:
        # 1. Parse UserParameters (these are the manual overrides from the UI)
        raw_params = job_data.get("actionConfiguration", {}).get("configuration", {}).get("UserParameters", "{}")
        user_parameters = json.loads(raw_params)
        
        # 2. Get S3 Artifact details
        input_artifact = job_data["inputArtifacts"][0]
        bucket_name = input_artifact["location"]["s3Location"]["bucketName"]
        object_key = input_artifact['location']['s3Location']['objectKey']
        
        # Download artifact using temp credentials
        temp_creds = job_data.get("artifactCredentials", {})
        s3_temp_client = boto3.client(
            "s3", 
            aws_access_key_id=temp_creds["accessKeyId"], 
            aws_secret_access_key=temp_creds["secretAccessKey"], 
            aws_session_token=temp_creds["sessionToken"]
        )

        response = s3_temp_client.get_object(Bucket=bucket_name, Key=object_key)
        zip_content = response['Body'].read()
        
        # 3. Read the default components from the S3 input.json
        with zipfile.ZipFile(io.BytesIO(zip_content)) as z:
            with z.open("input.json") as f:
                input_data = json.load(f)
        
        s3_components = input_data.get("components", [])
        print(f"Components found in S3 file: {s3_components}")
        print(f"Manual UserParameters received: {user_parameters}")

        # 4. Resolve the final component list
        # We check each possible component. If user provided a value, use it. 
        # Otherwise, check if it exists in the S3 file.
        all_possible_components = ['datastore', 'portal', 'server', 'webadapter']
        updated_components = []

        for comp in all_possible_components:
            # Check if user explicitly typed "true" or "false" in Pipeline UI
            user_val = user_parameters.get(comp)
            
            # Logic: Only override if it's NOT our placeholder and NOT empty
            if user_val and str(user_val).upper() != "FROM_CONFIG":
                # Scenario: Manual Trigger. Convert string/bool to boolean
                is_enabled = str(user_val).lower() == "true"
                if is_enabled:
                    updated_components.append(comp)
                print(f"Component '{comp}' resolution: Manual Override ({is_enabled})")
            else:
                # Scenario: Automatic Trigger. Use S3 value.
                if comp in s3_components:
                    updated_components.append(comp)
                    print(f"Component '{comp}' resolution: S3 Fallback (Enabled)")
                else:
                    print(f"Component '{comp}' resolution: S3 Fallback (Disabled)")

        # Update the payload
        input_data["components"] = updated_components
        print(f"Final resolved components for Step Function: {updated_components}")

        # 5. Pack back into a zip for the output artifact
        output_artifact = job_data["outputArtifacts"][0]
        output_bucket = output_artifact["location"]["s3Location"]["bucketName"]
        output_key = output_artifact["location"]["s3Location"]["objectKey"]

        output_zip_buffer = io.BytesIO()
        with zipfile.ZipFile(output_zip_buffer, 'w', zipfile.ZIP_DEFLATED) as z:
            z.writestr("input.json", json.dumps(input_data, indent=2))
        
        s3_client.put_object(
            Bucket=output_bucket, 
            Key=output_key, 
            Body=output_zip_buffer.getvalue()
        )

        # 6. Signal success to CodePipeline
        codepipeline_client.put_job_success_result(
            jobId=job_id,
            outputVariables={
                'stepFunctionInput': json.dumps(input_data)
            }
        )

        return {'statusCode': 200, 'body': 'Success'}

    except Exception as e:
        print(f"Error: {str(e)}")
        codepipeline_client.put_job_failure_result(
            jobId=job_id,
            failureDetails={'message': str(e), 'type': 'JobFailed'}
        )
        return {'statusCode': 500, 'body': str(e)}
