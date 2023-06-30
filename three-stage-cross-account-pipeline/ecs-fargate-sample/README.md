# Fargate ECS Docker CodePipeline Proof of Concept

This Git repository contains a Java sample application that uses Spring Boot to create a "Hello World" API. The repository includes all the necessary files and configurations to build the application, create a JAR file, and deploy it using AWS CloudFormation and Amazon Elastic Container Service (ECS) with Fargate.

## Deployed Resources

- An [AWS ECS Cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html) groups together tasks, and services.
- A [task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) is a blueprint for your application. It is a text file in JSON format that describes the parameters and one or more containers that form your application
- An [ECS Task execution role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html) - grants the Amazon ECS container and Fargate agents permission to make AWS API calls on your behalf
- A [Task IAM role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html)
- An Autoscaling role that gives AWS permission to perform autoscaling events
- Two [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) - one for the autoscaling group and one for your ECS Service.
- An [ECS Service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) containing 1 or more autoscaling instances of the Docker container with the sample API.
- An [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)

## Directory structure

```bash
.
├── README.md                               -- This file
├── buildspec-fargate.yaml                  -- used for the CodeBuild Deployment phase
├── buildspec-integration.yaml              -- used for the CodeBuild integration phase
├── components
│   ├── deploy-subdirectory-templates.sh    -- iterates through the child folders and deploys templates
│   ├── deploy-template.sh                  -- deploys a single template with sam
│   ├── deploy.sh                           -- wrapper for consistency
│   ├── ecs 
│   │   ├── fargate.json                    -- maps environment variables to fargate stack
│   │   └── fargate.yml                     -- used to deploy and update the fargate ECS service
├── configuration                           
│   └── tag-options.json                    -- config file used to tag resources created by the pipeline
├── deploy.sh                               -- deploys this repository
├── docker-rest-api                         -- sample API
│   ├── Dockerfile                          -- sample Dockerfile
│   ├── pom.xml                             -- Maven sample file
│   ├── src                                 -- source code for the API
├── fargate-envs.sh                         -- environment variables containing settings for Fargate
├── scripts                                 -- helper scripts
├── target-account                          -- resources for target accounts
│   ├── codebuild-fargate.json              -- maps environment variables to Codebuild role template
│   ├── codebuild-fargate.yml               -- creates Codebuild role for cross account access

```

## Populating Parameter values

Each CloudFormation template can have an optional corresponding ```.json``` file.  The template that is used to deploy the container is at [./components/ecs/fargate.yml](./components/ecs/fargate.yml).

The corresponding JSON file is used to map environment variables to CloudFormation parameters.

```json
{
    "Configuration": [
        {
            "Key":"StackName",
            "Value":"${FargateStackName}",
            "Description":"This is the name of the Stack.  Ugly hack."
        },
        {
            "Key": "VPC",
            "Value": "${VPC}"
        },
        {
            "Key": "SubnetA",
            "Value": "${SubnetA}"
        }
```

The ```fargate-env.sh``` is used to assign values to the environment variables.

## Deployment

- Launch AWS CloudShell in the *target* account where you want to deploy your code.
- Modify the ```fargate-envs.sh``` file to contain the variables for your environment.  See the comments in the file for more information.
- Ensure that the target account has [permission to access ECR in the shared account.](https://repost.aws/knowledge-center/secondary-account-access-ecr)

- Run the following commands:

```bash
# The Account number to the account containing your CodePipeline
export DevOpsAccount=1234567890 
# The name of the role to be assumed by CodeBuild.  It must start with 'codebuild-'
# Note the name, you will need it later
export RoleName=codebuild-fargate-role

export FrameworkScriptsDir=$(pwd)/scripts
export TagFile=$(pwd)/configuration/tag-options.json
pushd ./target-account
bash deploy.sh
popd
```

- Create an AWS CodePipeline using Service Catalog

![Parameters-1](./images/2023-06-23-19-15-52.png)
![Parameters-2](./images/2023-06-23-19-14-31.png)

## Modifying your repository to work with the Fargate based cross account AWS CodePipeline

### Copy the necessary files to the root directory of your  repository:

1. ```./components```
2. ```./scripts``` folder -  contains helper scripts used for building and deploying files.
3. ```./buildspec-integration.yaml``` - used in the ```AWS CodeBuild integration phase```.  Run your automated tests and static code analysis tools here.
4. ```./buildspec.yaml``` - used in the ```AWS CodeBuild Deployment Phase``` to build and deploy your code to the target account.
5. ```./build.sh``` - builds the Docker container
6. ```./fargate-envs.sh``` - contains environment variables that map to the Fargate CloudFormation template used for deployment

### Modify the necessary files

#### Buildspec file modifications

Add static code analysis and automated test commands to the  ```buildspec-integration.yaml``` file.

The ```buildspec.yaml``` file is generic.  Environment specific values are controlled by environment variables.
You can load environment specific variables by changing this line:

````bash
      - source $CODEBUILD_SRC_DIR/fargate-envs.sh
````

To this:

```bash 
      - source $CODEBUILD_SRC_DIR/fargate-envs-$Environment.sh
```

and adding environment specific shell scripts.  The $Environment variable is predefined when using the
Service Catalog product to create the CodePipeline.


#### Modify the build.sh file.

Modify the ```build.sh``` shell script to build any artifacts your deployment needs.

#### Working with test reporting in AWS CodeBuild

Please see the [included documentation](./TEST-REPORTS.md) for information about integrating automated tests.


