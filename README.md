# AWS Service Catalog Framework with Cross Account CodePipelines

This repository consists of a framework to deploy an [AWS Service Catalog](https://aws.amazon.com/servicecatalog/) Portfolio and a [Cross Account CodePipeline](three-stage-cross-account-pipeline-sc-product/README.md) product.

## Features

### Deploying products

When deploying a Service Catalog product with AWS CloudFormation, you need to specify the Portfolio and the Product defined by a CloudFormation template stored in [Amazon S3](https://aws.amazon.com/s3/).  

By default, CloudFormation will not update the corresponding product in the Portfolio
when you update the corresponding template in S3. CloudFormation only knows to update a resource when one of its properties changes.  This framework corrects that by renaming the template in S3 when the contents of the template changes based on the [MD5 checksum](https://docs.aws.amazon.com/AmazonS3/latest/userguide/checking-object-integrity.html).

### Tag Option library support

The Service Catalog [TagOption library](https://docs.aws.amazon.com/servicecatalog/latest/adminguide/tagoptions.html) makes it easier to enforce the following:

- A consistent taxonomy
- Proper tagging of Service Catalog resources
- Defined, user-selectable options for allowed tags

Any resources created when you launch a product automatically get tagged by the configured tag 
options.

To create a Tag Option for a portfolio using CloudFormation, you have to create a separate [AWS::ServiceCatalog::TagOption](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-servicecatalog-tagoption.html) to add it to the library and create a [AWS::ServiceCatalog::TagOptionAssociation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-servicecatalog-tagoptionassociation.html) to associate with a portfolio. 

The framework automatically creates these resources for you by reading from a JSON formatted [tag file](./TAGGING.md).

### Adding roles to the Portfolio

Roles must be explicitly assigned to the portfolio to be able to launch a product.  This framework includes a [CloudFormation custom resource](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html) that will automatically assigns a role based on the [IAM managed policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html) attached. 

By default, it will allow roles with the ```ServiceCatalogEndUser``` and ```ServiceCatalogAdminstrator``` managed policies.

### Concurrency issues

There are concurrency issues when deploying Service Catalog with CloudFormation.  
A [custom resource](./components/lambdas/lmd-csr-sleep/README.md) is included that works around that an issue.

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


### AWS Cloud 9 Prerequisites

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

### Adding products to the Portfolio

To add products to the portfolio, see [product deployment](./PRODUCT_DEPLOYMENT.md).

## References

- [Service Catalog Overview](./SERVICE_CATALOG_OVERVIEW.md)
- [Service Catalog Adminstration](./SERVICE_CATALOG_ADMINSTRATION_OVERVIEW.md)
- [Using Service Catalog](./USING_SERVICE_CATALOG.md)
- [Repository Structure](./REPOSITORY_STRUCTURE.md) 
- [Product Deployment](./PRODUCT_DEPLOYMENT.md)
