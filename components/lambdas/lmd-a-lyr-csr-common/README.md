# Common Lambda Layer

[Lambda layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html) provide a convenient way to package libraries and other dependencies that you can use with your Lambda functions. Using layers reduces the size of uploaded deployment archives and makes it faster to deploy your code.

The ```[cfn-response](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-lambda-function-code-cfnresponsemodule.html)``` module is used to send a properly formatted response from a Lambda CloudFormation custom resource.

The layer contains a modified version that allows the Lambda to send a more detailed error to CloudFormation.
