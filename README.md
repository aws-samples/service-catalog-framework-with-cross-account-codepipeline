# AWS Service Catalog Framework with Cross Account CodePipelines

This repository consists of a framework to deploy an AWS Service Catalog Portfolio and sample Service Catalog Products.

- [ a Cross Account CodePipeline to deploy infrastructure](three-stage-cross-account-pipeline-sc-product/README.md).


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
- [The Simple Three Stage Pipeline](./CODEPIPELINE_PRODUCT.md)

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

### Deploying solution

#### Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS SAM](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/prerequisites.html) 

Verify that you have at least version 1.88

```bash
sam --version 
```

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) When deploying locally instead of using CloudShell, the deployment script uses Docker to build the Lambdas with the proper dependencies.


#### Deploying from Macs

Macs generally ship with older versions of Unix utilities.  Ensure that you have the latest version of:

- [bash](https://formulae.brew.sh/formula/bash)
- [coreutils](https://formulae.brew.sh/formula/coreutils)


### Deploying from AWS Cloud 9

When using AWS Cloud 9, the build process uses Docker to create the necessary AWS Lambda. 
By default, the EC2 instance supporting Cloud 9 only has 10GB of storage.

Please see the [AWS Cloud 9 setup instructions](./CLOUD9_SETUP.md) to create the necessary environment.


Ensure that you have the latest version of SAM.

```bash
# AWS Cloud9 does not have the sudo password set.  Set it.
sudo passwd ec2-user
curl -fsSL https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip --output aws-sam-cli-linux-x86_64.zip
sudo ./sam-installation/install

```


### Deploying the solution

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
export Repository="service-catalog"
export Branch="master"
# Deploy the Service Catalog Framework and the CodePipeline Service Catalog Product
bash deploy.sh
```

## Repository Structure

See [Repository Structure](./REPOSITORY_STRUCTURE.md) for a description of the files in the repository.

