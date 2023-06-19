"""
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
"""

# https://github.com/aws-samples/cloudformation-custom-resource-attach-latest-lambda-layer

import boto3
import cfnresponse
import functools
import time


def handler(event, context):
    responseData = {}
    print('EVENT:[{}]'.format(event))
    try:
        if event['RequestType'].upper() == 'UPDATE' or event['RequestType'].upper() == "CREATE":
            layer_name = event["ResourceProperties"]["LayerName"]
            lambda_name = event["ResourceProperties"]["LambdaName"]

            lambda_client = boto3.client('lambda')
            
            # Find the latest version of the Lambda layer specified
            layer_versions = lambda_client.list_layer_versions(LayerName=layer_name)
            max_version = functools.reduce(lambda x, y: x if x["Version"] > y["Version"] else y, layer_versions["LayerVersions"])
            while True:
                lambda_configuration = lambda_client.get_function(FunctionName=lambda_name)
                state = lambda_configuration["Configuration"]["LastUpdateStatus"]
                print(lambda_configuration)
                if state == "InProgress":
                     time.sleep(5)
                elif state != "Successful":
                     raise Exception(f"Last update for the function ${lambda_name} failed.")
                else:
                    break



            # Retrieve all of the existing Lambda layers of the Lambda
            # and remove the one we want to update if it exists.
            lambda_configuration = lambda_client.get_function_configuration(FunctionName=lambda_name)
            existing_layers = [] if "Layers" not in lambda_configuration else list(filter(lambda x: x["Arn"].split(":")[6] != layer_name,lambda_configuration["Layers"]))

            # Create a list that combines the existing layers without the one we want to update
            # and the newest version of the specified layer
            lambda_layers = [] if len(existing_layers) == 0 else list(map(lambda x: x["Arn"], existing_layers))
            lambda_layers.append(max_version["LayerVersionArn"])

            # Update the Lambda layer
            lambda_client.update_function_configuration(FunctionName=lambda_name, Layers=lambda_layers)
            print("Updated Lambda function: '{0}' with new layer: {1}".format(lambda_name, max_version))

            responseValue = 120
            responseData['Data'] = responseValue
            cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData)
            while True:
                lambda_configuration = lambda_client.get_function_configuration(FunctionName=lambda_name)
                if lambda_configuration["LastUpdateStatus"] == "InProgress":
                     time.sleep(5)
                elif lambda_configuration["LastUpdateStatus"] == "Failed":
                     raise Exception(f"Last update for the function ${lambda_name} failed.")
                break

        else:
            cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData)

    except Exception as e:
        print(f"An error has occured: {str(e)}")
        cfnresponse.send(event, context, cfnresponse.FAILED, responseData)

