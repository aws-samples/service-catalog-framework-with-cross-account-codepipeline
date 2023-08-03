# Sharing Quick Start

To make your Service Catalog products available to users who are not in your AWS accounts, you share your portfolios with them. You can share in several ways, including account-to-account sharing, organizational sharing, and deploying catalogs using stack sets.

This implementation supports account-to-account sharing and organizational sharing.

## Account to Account Sharing

To share a portfolio with an AWS account

Open the [Service Catalog console](https://console.aws.amazon.com/servicecatalog/).

In the left navigation menu, choose ```Portfolios``` and then select the portfolio you want to share. 

![Portfolios](./images/2023-07-12-13-33-46.png)

In the Actions menu, select ```Share```.

![Share](./images/2023-07-12-12-57-40.png)

In Enter account ID enter the account ID of the AWS account that you are sharing with. (Optional) Select TagOption Sharing. Then, choose Share.

### Automated syncing of shared portfolios

When a change is made to shared portfolio:

1. An event is sent to [Amazon CloudTrail](https://aws.amazon.com/cloudtrail/)
2. An [Amazon Event Bridge](https://aws.amazon.com/eventbridge/) rule is configured to listen for relevant Service Catalog events.
3. The EventBridge event triggers an [Amazon Lambda](https://aws.amazon.com/lambda/) function - ```sc-autopilot-importer```.
4. The ```sc-autopilot-importer``` creates a local Service Catalog Portfolio in the spoke accounts if necessary and copies the product from the hub account.

![Diagram](./images/2023-07-12-15-17-06.png)


## Deployment

This walkthrough assumes that you are *not*  deploying from either the [Organization root account](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_getting-started_concepts.html) or using a [delegated admin](https://aws.amazon.com/blogs/mt/cloudformation-stacksets-delegated-administration/) account.

### Deploy the necessary role in the spoke accounts

The deployment processes uses [CloudFormation Stacksets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html) to deploy resources to the spoke accounts where you will be sharing your portfolio.

Each spoke or target account needs to have a ```AWSCloudFormationStackSetExecutionRole``` for the CloudFormation service to assume.

The procedure below will be different depending on whether the ```AWSCloudFormationStackSetExecutionRole``` already exists.  Before preceding, go to the IAM page in the spoke account and check to see if the role exists.

#### Adding the hub account to an existing role

Go to the IAM web page on the console and add the account containing the Service Catalog Portfolio you would like to share to the trust policy.

#### Creating a new role

1. Download the [AWSCloudFormationStackSetExecutionRole](service-catalog-codepipeline-sc-dhhs/components/shared-products-resources/spoke-account-templates/AWSCloudFormationStackSetExecutionRole.yml) template to your local computer.
2. Choose ```Create Stack``` and then ```with new resources```
3. ```Upload a template file``` and upload the template from step #1.
4. For the stackname, type ```AWSCloudFormationStackSetExecutionRole``` and for the ```HubAccount``` parameter, type the name of the AWS Account containing your ServiceCatalogPortfolio.
