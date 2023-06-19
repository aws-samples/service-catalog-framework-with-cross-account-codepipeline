import cfnresponse
import time
import json

def lambda_handler(event, context):
    print(json.dumps(event))
    try:
        props = event['ResourceProperties']
        seconds = int(props["SleepSeconds"]) if "SleepSeconds" in props else 5;
        print("seconds - ",seconds)
        if event["RequestType"] == "Delete":
            cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
        time.sleep(seconds)
        cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
    except Exception as e:
        print(e)
        cfnresponse.send(event, context, cfnresponse.FAILED, {})