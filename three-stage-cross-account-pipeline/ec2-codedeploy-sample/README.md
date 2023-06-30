# Integrating AWS CodeDeploy with CodePipeline

[AWS CodeDeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html) is a deployment service that automates application deployments to Amazon EC2 instances, on-premises instances, serverless Lambda functions, or Amazon ECS services.

This project uses CodeDeploy to deploy code to EC2 instances.

CodeDeploy supports both **in place deployment** and **blue/green deployments**.  We will be using an [in place deployment](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html#welcome-deployment-overview-in-place)

## Setup in the target account

### Creating Deployment Groups

In an EC2 deployment, a deployment group is a set of individual instances targeted for a deployment. We will identify the instances that belong to a deployment group based on tags.  

Currently, the framework is configured to use one tag key/value combination. You will need to determine the tag key and value that identifies your deployment group and tag the target EC2 instances accordingly.

### Installing the CodeDeploy agent

The CodeDeploy agent must be [installed on the EC2 instance](https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-linux.html)

You can log into the EC2 instance via SSH or preferable via [Session Manager System Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started.html) and run the following commands to install CodeDeploy.

```bash
####
sudo yum install ruby
sudo yum install -y https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/codedeploy-agent.noarch.rpm
sudo service codedeploy-agent start
# verify installation
sudo service codedeploy-agent status
```

There is a sample [CloudFormation template](./misc/vpc-with-ec2.yml) that will create a VPC with an EC2 instance that is accessible via Session Manager if you don't already have one.  It will need to be tagged appropriately to be added to the CodeDeploy deployment group as explained above.



### Deploying resources to the target account via AWS CloudShell

The most straightforward method to deploy the prerequisites to the target account is via [AWS Cloudshell](https://aws.amazon.com/cloudshell/).

Log into the target account, clone this repository and run the following commands.

```bash
export Application="<the name of the application>"
export Environment="<Your environment>"
export EC2TagKey="<the key that specifies the EC2 deployment group>"
export DevOpsAccount="<the AccountId of the DevOps Account"
export EC2TagValue="<the value of the tag specified above>"
export BASEDIR=$(pwd)
export ScriptsDir=$BASEDIR/scripts
export TagFile=$BASEDIR/configuration/tag-options.json
pushd target-account
bash deploy.sh
popd

```

Take a note of the value of the  CodeBuildRole

```bash
----------------------------------------------------------------------------------------------------
Outputs                                                                                            
----------------------------------------------------------------------------------------------------
Key                 CodeBuildRole                                                                  
Description         Cross Account Code Build Role                                                  
Value               codebuild-acme-dev-us-east-1                                                   
----------------------------------------------------------------------------------------------------
```

## Launch a CodePipeline product 

- Repository - <the name of your repository>
- Branch - <the branch>
- IntegrationBuildSpec - ./buildspec-integration.yaml
- DeploymentBuildspec - ./buildspec.yaml
- TargetRole - <use the role created in the prior step. In this example ```codebuild-acme=dev-us-east-1```
- Application <should match the Application value specified above>

## Repository configuration

This project includes a [sample Linux Application](../SampleApp_Linux/) to demonstrate deploying an application onto a Linux.  

### Creating a CodeBuild buildspec file.

The [buildspec file](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) controls the build and deployment process.  You will need a buildspec file modeled after the [included sample](./buildspec-codedeploy.yaml) to deploy to the EC2 instance.


## Monitoring the deployment.

Orchestrating the deployment is done via a CodePipeline deployed in your DevOps account.  If the cross account deployment fails, the CodePipeline will fail.

To monitor the progress of the CodeDeploy application in more detail, log into the target account, navigate to the CodeDeploy page and click on your application.

![deployment application](./images/2023-05-30-18-59-50.png)

Then you can click on the Deployment Group.

![deployment group](./images/2023-05-30-19-03-58.png)

to see a list of deployments

![deployments](./images/2023-05-30-19-04-46.png)

If a deployment fails, notice that CodeDeploy will automatically roll back to the prior successful deployment.

You can drill down to the events for further troubleshooting.

![view events](./images/2023-05-30-19-07-34.png)

## Modifying your repository to work with the EC2 based cross account AWS CodePipeline

### Copy the necessary files to the root directory of your  repository:

1. ```./scripts``` folder -  contains helper scripts used for building and deploying files.
2. ```./buildspec-integration.yaml``` - used in the ```AWS CodeBuild integration phase```.  Run your automated tests and static code analysis tools here.
3. ```./buildspec.yaml``` - used in the ```AWS CodeBuild Deployment Phase``` to build and deploy your code to the target account.
4. ```./SampleApp_Linux/appspec.yml``` - used by ```AWS CodeDeploy```.  See usage [here](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html)
5. ```./build.sh```

### Modify the necessary files

#### Buildspec file modifications

Add static code analysis and automated test commands to the  ```buildspec-integration.yaml``` file.

Modify the second parameter following line to specify the directory containing the files 
that should be copied to the target EC2 instance.

```bash 
      - bash $ScriptsDir/start-deployment.sh $S3Bucket $BASEDIR/SampleApp_Linux "$CF_OUT_CodeDeployApplication" "$CF_OUT_CodeDeployDeploymentGroup"  
```

#### Modify the build.sh file.

Since this sample does not need to build any artifacts, the ```build.sh``` file is empty,  

Modify the shell script to build any artifacts your deployment needs.


