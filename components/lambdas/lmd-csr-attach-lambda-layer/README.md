# Attach Lambda Layer custom resource

[CloudFormation custom resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html) enable you to write custom provisioning logic in templates that AWS CloudFormation runs anytime you create, update (if you changed the custom resource), or a delete stack.

[AWS CloudFormation](https://aws.amazon.com/cloudformation/) does not support referencing "the latest version" of a layer when creating a Lambda function. This becomes problematic when the layer was created outside of your CloudFormation template.

CFNAttachLambdaLayer allows you to specify a Lambda and the Layer name that will be attached to it. It will attach the latest version of the Layer to the specified Lambda.

## Usage

```yaml
Parameters:
  Nonce:
    Type: String
    Description: Forces custom resource to run everytime CF runs -- pass in a $RANDOM as a parameter

  AttachLayer:
    Type: Custom::LayerAttachment
    Properties:
      LayerName: <Your Layer name>
      LambdaName: <Lambda name or ARN>
      #CloudFormation will not execute the custom resource if no properties are changed.
      #Along with the parameter, this ensures that the resource is called each time CloudFormation runs
      Nonce: !Ref Nonce
      ServiceToken: !ImportValue CFNAttachLambdaLayer
```
