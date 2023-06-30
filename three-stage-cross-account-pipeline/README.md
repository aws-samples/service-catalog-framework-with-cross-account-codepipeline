# Service Catalog CodePipeline product

## Features

The AWS Cross Account CodePipeline Service Catalog Product provides a number of features:

### An opinionated standardized directory structure

The Service Catalog Framework, the AWS CodePipeline product and the sample serverless [Elastic Container Service](https://aws.amazon.com/ecs/) [AWS Fargate](https://aws.amazon.com/fargate/) [repository](../ecs-fargate-sample/) all provide a standardize directory structure and helper scripts to ease deployment.

The directory structure is based on "components" with subdirectories for the individual components that your deployment needs like S3 buckets, Lambdas and roles.  When your CloudFormation templates are placed in this structure they automatically are scanned with static analysis tools and deployed with [AWS SAM](https://aws.amazon.com/serverless/sam/).

### Automatic static analysis tool scanning

All CloudFormation templates are scanned with [CFN Lint](https://github.com/aws-cloudformation/cfn-lint) and [CFN Nag](https://github.com/stelligent/cfn_nag).

Python based Lambda functions are also scanned with [Bandit](https://bandit.readthedocs.io/en/latest/).

### Configurable CloudFormation parameter overrides

Each of your CloudFormation templates can have a corresponding [json file](../configuration/tag-options.json) that maps environment variables to CloudFormation parameters.  This allows you to give your templates a separate set of values depending on the target deployment environment.

See the accompanying [documentation](../scripts/convert-config-to-kv-pairs.md) for more information.

### Support for consistent tagging of all deployed applications

You can specify a [configuration file](../configuration/tag-options.json) that tells the build process how the deployed resources should be [tagged](https://docs.aws.amazon.com/tag-editor/latest/userguide/tagging.html).  The values for the tags can either be hard coded or map to environment variables.

## What is CodePipeline?

[AWS CodePipeline](https://aws.amazon.com/codepipeline/) is a fully managed continuous delivery service that helps you automate your release pipelines for fast and reliable application and infrastructure updates.


## The Cross Account CodePipeline Product

![CodePipeline](./images/CodePipeline.png)

Once provisioned, this CodePipeline automatically runs when code is pushed to its source [CodeCommit](https://aws.amazon.com/codecommit/) repository.  It contains three stages after the source code is retrieved.


1. **CodeBuild Integration Phase**.  Here you can run any automated tests and static code scanning tools
2. **Deployment Approval**. This allows a Release Manager to either approve or reject the deployment based on the results of the Integration phase. 
3. **CodeBuild Deployment Phase**. This phase is meant to allow you to run any necessary commands to deploy your code. AWS CodeBuild, based on the buildspec file, will assume a role in the target account to allow for cross account deployments.

![Three Stage CodePipeline](./images/2023-03-31-14-54-41.png)


[AWS CodeBuild](https://aws.amazon.com/codebuild/) is a fully managed continuous integration service that compiles source code, runs tests, and produces ready-to-deploy software packages.

Your repository needs to have a [buildspec](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) with a list of commands to run. A sample buildspec file is in included for both the [integration phase](../buildspec-integration.yaml) and the [deployment phase](../buildspec.yaml).

## Service Catalog Portfolios and Products

This solution deploys one Service Catalog Portfolio.

![Service Catalog Portfolio](./images/2023-03-31-16-13-47.png)

which includes *products*...

![](./images/2023-04-21-15-35-44.png)

## Provisioning a product

From the Service Catalog web page, go to *Products*

Click on the *Cross Account Three stage AWS CodePipeline* and then click on *Launch Product*

![](./images/2023-04-21-15-37-48.png)

Now you can enter the name of the repository to deploy, the branch, the buildspec files, and the target account number.

![](2023-04-21-15-41-39.png)

Once you enter parameters, click on **Launch Product**.

Once you click on **Launch Product**, you can go to ```Provisioned products``` and see the created resources.

![Resources](./images/2023-04-21-15-37-50.png)

For a general overview about the user experience for Service Catalog, please see the [Using Service Catalog](../USING_SERVICE_CATALOG.md) documentation.

## Deployed Resources

### IAM Roles

Two IAM Roles are deployed

- [codebuild-codepipeline-role-${AWS::Region}](./components/codepipeline/simple-codepipeline.yml) -- the role used by [AWS CodePipeline](https://aws.amazon.com/codepipeline/).


### AWS EventBridge

An [An AWS EventBridge](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatch-Events-tutorial-codebuild.html) event is created that instantiates the pipeline when code is pushed to the source repository and branch.


### AWS CodePipeline

An AWS CodePipeline is deployed based on the name of the source [AWS CodeCommit](https://aws.amazon.com/codecommit/)

### Amazon S3

When AWS Codepipeline pulls the code from AWS CodeCommit, it zips the source code and copies it to an S3 bucket.  The S3 Bucket is then used throughout the pipeline.
### AWS CodeBuild

Two [AWS CodeBuild](https://aws.amazon.com/codebuild/) projects.

- An *Integration* CodeBuild Project
- A *Deployment* CodeBuild Project



## Using the Provisioned CodePipeline

The provided CodePipeline product can be used to deploy this reposity.

Two [Codebuild buildspec files](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) are included:

- [buildspec-integration.yaml](./buildspec-integration.yaml) -- used in the integration phase.  It runs static analysis tools for both the CloudFormation templates and the Python code.
- [buildspec.yaml](./buildspec.yaml) -- used in the deployment phase. 

Assuming this repository has been pushed to an [AWS CodeCommit](https://aws.amazon.com/codecommit/) repository named ```service-catalog-codepipeline```, the following parameter values will create a CodePipeline that will deploy the repository when you push updates to it.

![CodePipeline deployment parameters](./images/2023-04-21-15-41-39.png)


## Deployment 


## Deploying the Service Catalog Product

### Deploy the Service Catalog Product

The most straightforward method to deploy this solution involves logging into your AWS account with the appropriate permissions and using [AWS CloudShell](https://aws.amazon.com/cloudshell/)

Log into your AWS account, navigate to the CloudShell page and clone the repository.


After you clone the repository, run the following commands.

```bash

# These environment variables are referenced in the configuration file.
# Set the TargetAccount to the current accountnumber
export TargetAccount=$(aws sts get-caller-identity  | jq -r ".Account")
export Repository="x-acct-codepipeline"
export Branch="main"

# if the Service Catalog Framework hasn't been deployed, deploy it first
bash deploy.sh

#
bash deploy-service-catalog-product.sh ./three-stage-cross-account-pipeli
ne-sc-product/cross-account-codepipeline.yml ./three-stage-cross-account-pipeline/cross-account-codepipeline.json x-acct-pipeline-product
```

### Deploy IAM Roles to allow cross account deployments

Use your temporary credential to change to the target account where the
resources will be deployed or log in to the target account and clone the repository.

This will create an IAM role in the target account that can be assumed by the DevOps CodeBuild role
to deploy resources to this account.

```bash
bash deploy-template.sh s3/x-acct-codepipeline-sourcebucket.yml
bash deploy-template.sh roles/x-acct-codebuild-role.yml
```
