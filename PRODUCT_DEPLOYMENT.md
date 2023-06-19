# Deploying a Service Catalog Product

Once the [AWS Service Catalog Framework has been deployed](./FRAMEWORK_DEPLOYMENT.md), you can add products to the portfolio.

The framework includes a bash shell script to enable the deployment.

## Using the bash script

The bash shell script ```deploy-service-catalog-product.sh``` requires three parameters:

- the path to a CloudFormation template 
- the path to the corresponding JSON configuration file containing the values for the CloudFormation template
- the name of the CloudFormation stack to Create or Update



### The configuration file format

You can find a sample configuration file [here](./simple-three-stage-pipeline/components/codepipelines/simple-codepipeline-sc-parameters.json).

The configuration file is processed by Python scripts during the deployment.  A description of how the configuration file is processed can be found in the [README](./scripts/README.md) file in the scripts folder.

### Deploying product specific prerequisites

Sometimes, you need to be able to deploy resources that are used across provisioned products.  If the folder containing your template has a bash script called ```deploy-prereqs.sh``` it will be run before your Service Catalog product is deployed.

This deploys the sample ```Three Stage CodePipeline```

```bash
# This is a sample product.  Comment this out to deploy just the Service Catalog Portfolio and
# Lambda custom resources.
bash deploy-service-catalog-product.sh \
     simple-three-stage-pipeline/components/codepipeline/simple-codepipeline.yml \
     simple-three-stage-pipeline/components/codepipeline/simple-codepipeline-sc-parameters.json \
    "three-stage-pipeline"
```
