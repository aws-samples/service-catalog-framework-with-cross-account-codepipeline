import cfnresponse
import boto3
import json

def lambda_handler(event, context):
    client = boto3.client('organizations')
    print(json.dumps(event))
    try:
        response = client.describe_organization()
        cfnresponse.send(event, context, cfnresponse.SUCCESS, 
        {
            "Arn":response["Organization"]["Arn"]
        },response["Organization"]["Id"])
    except Exception as e:
        print(e)
        cfnresponse.send(event, context, cfnresponse.FAILED, {})