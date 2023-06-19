# Sleep CloudFormation Custom Resource

[CloudFormation custom resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html) enable you to write custom provisioning logic in templates that AWS CloudFormation runs anytime you create, update (if you changed the custom resource), or a delete stack.

This custom resource is used to force CloudFormation to wait a configurable number of seconds between the time a dependent resource is created before another resource is created. 

It is used to work around a concurrency issue in the [AWS Service Catalog](https://aws.amazon.com/servicecatalog/) template.

## Usage


```yaml
Resources:
  WaitForProduct:
    Type: 'AWS::CloudFormation::CustomResource'
    Properties:
      ServiceToken: !ImportValue CFNSleep
      SleepSeconds: 20
  #Ugly hack: on create, LaunchRoleConstraint is started before the 
  #ProductId is available.  
  #This forces a 20 second sleep before the LaunchRoleConstraint creation
  #process is called based on the DependsOn
  LaunchRoleConstraint:
    Type: AWS::ServiceCatalog::LaunchRoleConstraint
    Condition: CreateConstraint
    # DependsOn forces this resource to wait 30 seconds before CloudFormation 
    # starts trying to create this resource
    DependsOn: 
      - WaitForProduct
    Properties: 
      LocalRoleName: !Sub "SCCloudFormationRole-${AWS::Region}"
      PortfolioId:  !Ref PortfolioId
      ProductId: !Ref 'ServiceCatalogCloudFormationProduct'
  ServiceCatalogCloudFormationProduct:
    Type: "AWS::ServiceCatalog::CloudFormationProduct"
    Properties:
      Name: !Ref 'SCProductName'
      Description: !Ref 'SCProductDescription'
      Owner: !Ref 'SCProductOwner'
      ProvisioningArtifactParameters:
        -
          Name: !Sub '${VersionDescription}'
          Description: !Sub '${ProvisioningArtifactDescriptionParameter}'
          Info:
            LoadTemplateFromURL: !Ref ProductUrl



```