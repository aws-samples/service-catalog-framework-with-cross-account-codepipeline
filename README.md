# AWS Service Catalog Framework with a Cross Account CodePipeline

This repository consists of a framework to deploy an AWS Service Catalog Portfolio and a [Cross Account CodePipeline](three-stage-cross-account-pipeline/README.md).


## What is Service Catalog?

[AWS Service Catalog](https://docs.aws.amazon.com/servicecatalog/latest/adminguide/introduction.html) lets you centrally manage deployed IT services, applications, resources, and metadata to achieve consistent governance of your infrastructure as code (IaC) templates, Service Catalog consists of *products* and *portfolios*.

### Service Catalog Products

A *product* is an IT service that you want to make available for deployment on AWS. A product consists of one or more AWS resources, such as EC2 instances, storage volumes, databases, monitoring configurations, and networking components.

### Service Catalog Provisioned Products

AWS CloudFormation stacks make it easier to manage the lifecycle of your product by enabling you to provision, tag, update, and terminate your product instance as a single unit. An AWS CloudFormation stack includes an AWS CloudFormation template, written in either JSON or YAML format, and its associated collection of resources. A provisioned product is a stack. When an end user launches a product, the instance of the product that is provisioned by Service Catalog is a stack with the resources necessary to run the product.

### Service Catalog Portfolios

A portfolio is a collection of products that contains configuration information. Portfolios help manage who can use specific products and how they can use them. With Service Catalog, you can create a customized portfolio for each type of user in your organization and selectively grant access to the appropriate portfolio.


## Deployed Resources

- [The Service Catalog Framework](./FRAMEWORK_DEPLOYMENT.md)
- [A Cross Account AWS CodePipeline](./three-stage-cross-account-pipeline/README.md)

## Deployment

You can deploy the Framework via either CloudShell or locally.

To change the region for the deployment, set the [AWS_REGION and AWS_DEFAULT_REGION environment variables  to the desired region](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)

### Using AWS CloudShell

The most straightforward method to deploy this solution involves logging into your AWS account with the appropriate permissions and using [AWS CloudShell](https://aws.amazon.com/cloudshell/)

Log into your AWS account, navigate to the CloudShell page and clone the repository.

```bash
# Deploy the Service Catalog Framework and the CodePipeline Service Catalog Product
bash deploy.sh
```

### Deploying locally

#### Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS SAM](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/prerequisites.html) 
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) When deploying locally instead of using CloudShell, the deployment script uses Docker to build the Lambdas with the proper dependencies.


Macs generally ship with older versions of Unix utilities.  Ensure that you have the latest version of:

- [bash](https://formulae.brew.sh/formula/bash)
- [coreutils](https://formulae.brew.sh/formula/coreutils)

```bash
brew install bash
# install coreutils
brew install coreutils
# Use the coreutils version of the "realpath" command instead of the built in version
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
```

From the terminal, after you clone the repository, run the following commands.

```bash
pip3 install -r requirements.txt
npm install -g cfn-include
sudo yum install jq
export TargetAccount=$(aws sts get-caller-identity  | jq -r ".Account")
# Deploy the Service Catalog Framework and the CodePipeline Service Catalog Product
bash deploy.sh
```



