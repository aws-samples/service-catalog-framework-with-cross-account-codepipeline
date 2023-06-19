# Deploying the Service Catalog Framework

The included framework is designed to demonstrate deploying a Service Catalog Portfolio and one or more Service Catalog products.

It includes a sample [buildspec file](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) for use with [AWS CodeBuild](https://aws.amazon.com/codebuild/). However, most of the deployment steps are in a bash shell script to enable initial bootstrapping and to enable a CI/CD process with a tool you choose,

## Deployed Components

This solution deploys a few  [AWS Lambda Custom Resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html) that extend CloudFormation to support the Service Catalog implementation and one [Service Catalog Portfolio](./SERVICE_CATALOG_OVERVIEW.md).  


### AWS Lambda CloudFormation Custom Resources


- [Common Library AWS Lambda Layer](./components/lambdas/lmd-a-lyr-csr-common/) This contains a modified version of the [AWS cfnresponse module](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-lambda-function-code-cfnresponsemodule.html) used to coordinate with CloudFormation when creating custom resources.
- [Attach Lambda Layer](./components/lambdas/lmd-a-lyr-csr-common/README.md) There are limitations with deploying Lambda Layers and the Lambdas that they depend on from different stacks.  This overcomes those limitations.
- [Attach Role to Service Catalog Portfolio](./components/lambdas/lmd-csr-attach-role-to-sc-portfolio/README.md) - Allows you to specify which roles should be able to access a Service Catalog Portfolio based on attached IAM policies.
- [Sleep](./components/lambdas/lmd-csr-sleep/README.md) - There are concurrency issues when creating Service Catalog related issues.  This is a simple Lambda that forces CloudFormation to pause before creating dependent resources.

### IAM Roles

Each Lambda listed above deploys IAM Roles with policies properly scoped with least privilege needed to function.

In addition, this deployment also deploys a ```SCCloudFormationRole``` that Service Catalog uses to provision products on behalf of the user.  You will need to add permissions specific to your products to this role.

### Service Catalog Portfolio

One Service Catalog Portfolio is created using the ```Default``` values.

## Helper scripts

Please see the [README](./scripts/README.md) in the ```scripts``` folder for information about the helper scripts.

## Static code scanning

As part of the deployment process, you can run static code analysis using the following open source tools by running the ```scan.sh``` bash shell scripts.

- [cfn_lint](https://github.com/aws-cloudformation/cfn-lint) - CloudFormation linter
- [cfn-nag](https://github.com/stelligent/cfn_nag) - CloudFormation security/best practices static code analysis.
- [Bandit](https://github.com/PyCQA/bandit) - Python static code analsys. 

## Deployment

The easiest method to do the initial deployment is via [AWS CloudShell](https://aws.amazon.com/cloudshell/). 

Using AWS CloudShell, a browser-based shell, you can quickly run scripts with the AWS Command Line Interface (CLI), experiment with service APIs using the AWS CLI, and use other tools to increase your productivity.

Log into your AWS Account and navigate to the ```CloudShell``` service.

Once the prompt is available, clone the repository and type the following commands:

```bash

# Before running, ensure that IAM roles that should have permission to access the Portfolio 
# have an IAMPolicy attached of eith ServiceCatalogEndUser or ServiceCatalogAdministrator set.


sudo npm install -g cfn-include
sudo pip3 install cfn_flip
sudo pip install bandit
sudo gem install cfn-nag

cd <Your Repository directory>

pushd components/lambdas
## runs static analysis tools on CloudFormation templates and Lambda Python code
bash scan.sh
bash deploy.sh

popd
pushd components/service-catalog-portfolio
bash deploy.sh
```


## Extending the framework


At times, your product may require the deployment of dependencies that all products depend on.  
By convention, those resources should be placed in a ```./components``` 


### Using CloudFormation parameters

If your template needs [CloudFormation Parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html),
you can specify the parameters in a separate [configuration file](./scripts/(README.md), The configuration file should have the same name
as your template with an extension of ```.json```.  You can  add a ```default``` value to the configuration file or you can specify values 
by setting the corresponding environment variables in the [buildspec file](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html#build-spec-ref-example)
or by attaching them in the [CodeBuild CloudFormation template](./simple-three-stage-pipeline-sc-product/codebuild-project.yml).

### Adding Resources

#### Lambdas

You can add new Lambdas to the process by adding a folder under ```components``` with the following structure.
They will automatically be scanned by static analysis tools and deployed by the ```deploy.sh``` script.

The deployment process uses [SAM](https://aws.amazon.com/serverless/sam/) to build the Lambdas


```bash
components/lambdas  
├── deploy.sh  
├── lmd-my-new-lambda (The name of your AWS Lambda)  
├──── README.md (documentation in Markdown format)  
├──── lmd-my-new-lambda.yml (a CloudFormation template with the same name as the folder)  
├──── src (a folder containing your source code)  
│     ├── index.py  
│     └── requirements.txt (a list of the Python modules that should be included)  

```

#### Other resources

All other resources can be deployed by placing the templates in their respective folders.  A stack will be deployed with
the same name as the template.


## More Information

- [Service Catalog User Guide](./SERVICE_CATALOG_OVERVIEW.md)
- [Service Catalog Administration Guide](./SERVICE_CATALOG_ADMINSTRATION_OVERVIEW.md)
