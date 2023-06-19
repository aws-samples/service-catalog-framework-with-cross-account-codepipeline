# Scanning Lambdas

This ```scan.sh``` script will perform static code analysis on all of the [AWS CloudFormation](https://aws.amazon.com/cloudformation/) templates found in subdirectories of the current directory and look for ```./src``` subdirectories and scan Python scripts.

It uses a combination of [cfn-lint](https://aws.amazon.com/cloudformation/) and [cfn-nag](https://github.com/stelligent/cfn_nag) to scan CloudFormation templates and [Bandit](https://bandit.readthedocs.io/en/latest/) to scan Python files.

## Static code analysis for CloudFormation templates

### Prerequisites for running locally

- [Docker Desktop](https://www.docker.com/products/docker-desktop/).  If you are running locally, the scanning process uses Docker to build in an environment similar to the one required by the Lambda runtime.
- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS Serverless Application Model](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
- [NodeJS](https://nodejs.org/en)
- [Python](https://www.python.org/downloads/)
- [CFN Nag](https://github.com/stelligent/cfn_nag)
- [CFN Flip](https://github.com/stelligent/cfn_nag)

### Running scans

```bash
export SuppressionFile=$(pwd)/suppression.txt
# Change to the directory containing the script
cd components/lambdas 
bash scan.sh $SuppressionFile
```

## Running Scan through the pipeline

The scan process is typically run as part of an [AWS CodePipeline](https://aws.amazon.com/codepipeline/).  With the including pipeline, it is run as part of the integration phase. If scanning fails.  The pipeline fails.

![pipeline failed](./images/2023-05-30-14-30-55.png)

To see where the failure occurred, click on ```View in CodeBuild``` and scroll down to the bottom to find the error.

![code deploy failed](./images/2023-05-30-14-36-46.png)