# Prerequisites


#### Deploying from Macs

- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS SAM](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/prerequisites.html) 

Verify that you have at least version 1.88

```bash
sam --version 
```

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) When deploying, the deployment script uses Docker to build the Lambdas with the proper dependencies.

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

### Deploying from AWS Cloud 9

When using AWS Cloud 9, the build process uses Docker to create the necessary AWS Lambda. 
By default, the EC2 instance supporting Cloud 9 only has 10GB of storage.

Please see the [AWS Cloud 9 setup instructions](./CLOUD9_SETUP.md) to create the necessary environment.


```bash
# AWS Cloud9 does not have the sudo password set.  Set it.
sudo passwd ec2-user
# Install the latest version of the AWS Serverless Application Model
curl -fsSL https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip --output aws-sam-cli-linux-x86_64.zip
sudo ./sam-installation/install
# Install jq
sudo yum install jq

```
