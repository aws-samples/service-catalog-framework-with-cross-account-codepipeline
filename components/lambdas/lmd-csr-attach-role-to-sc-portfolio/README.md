# Attach Role to Service Catalog Portfolio CloudFormation Custom Resource

A user's role has to be explicitly given permission to access a Service Catalog Portfolio in addition to the role having the required [IAM Permission](https://docs.aws.amazon.com/servicecatalog/latest/adminguide/controlling_access.html).

The native CloudFormation resource type [AWS::ServiceCatalog::PortfolioPrincipalAssociation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-servicecatalog-portfolioprincipalassociation.htm) allows you to specify a single role to associate with a Portfolio.  

The ```Attach Role to Service Catalog Portfolio``` custom resource, allows you to attach multiple roles to a Service Catalog Portfolio based on the attached policy.

## Usage

The following example will attach all roles to a Service Catalog Portfolio that have either the ```AWSServiceCatalogEndUserFullAccess``` or ```AWSServiceCatalogAdminFullAccess``` policy explicitly attached.

```yaml
  AttachRolesByPolicy:
    Type: Custom::AttachRolesByPolicy
    Properties:
      ServiceToken: !ImportValue CFNAttachRolesToPortfolio
      PolicyNames: 
        - AWSServiceCatalogEndUserFullAccess
        - AWSServiceCatalogAdminFullAccess
      PortfolioId: !Ref ServiceCatalogPortfolio
      Nonce: !Ref Nonce

  ServiceCatalogPortfolio:
    Type: "AWS::ServiceCatalog::Portfolio"
    Properties:
      ProviderName: AWS Samples
      Description: Sample Portfolio
      DisplayName: ACME Portfolio
```