# Helper Scripts

There are a number of helper scripts used during the deployment of the Service Catalog framework.

## Replace Environment Variables

The ```replace-environmnent-vars.py``` scripts parses a JSON file and outputs a second JSON file with the values either replaced with the specified ```Default``` value or an environment variable specified by surrounding the value with ```${}```.

The script will error if none of the conditions are met:

1. A static string is not specified for ```Value```
2. A value is not defined for the corresponding environment variable.
3. A ```Default``` value is not specified.


```json
    "Configuration":[
    {
        "Key": "PortfolioId",
        "Value": "${CF_OUT_ServiceCatalogPortfolio}",
    },
    {
        "Key": "ProductName",
        "Value":"${ProductName}",
        "Default": "Three stage AWS CodePipeline",
    }]
```

## Create Parameters

The ```convert-config-to-kv-pairs.py``` script accepts a JSON file that has been output by ```replace-environment-vars.py``` and creates a string that can be used as the value for the 
```--parameter-overrides``` or ```--tags``` parameter of the [sam deploy](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-deploy.html) command.

```bash
python3 $FrameworkScriptsDir/replace-environment-vars.py \
                    --json-file $ConfigFile > replaced-vars.tmp

export Parameters=$(python3 $ScriptsDir/create-parameters.py --json-file replaced-vars.tmp)
export Tags=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs --json-file replaced-vars.tmp --key-value-type tags)


echo $Parameters
sam deploy  --template-file  components/service-catalog-products/service-catalog-product.yml \
                        --stack-name $StackName \
                        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
                        --resolve-s3 \
                        --no-fail-on-empty-changeset \
                        --parameter-overrides "$Parameters" \
                        --tags "$Tags"
```

## Get Nested Templates

The ```get-nested-templates.py``` script is used to parse a CloudFormation template in yaml format and list the [nested templates](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html).

The nested templates are scanned when you run the ```scan.sh``` bash script.

```bash
export Templates=$(python3 $ScriptsDir/get-nested-templates.py --template-file $ProductTemplate)


pushd $(dirname $ProductTemplate)
for path in $(echo $Templates); do
    sam validate --template-file "$path"  --lint
    # add cfn_nag
done
popd
```

## Upload Service Catalog Products

When you send a CloudFormation template to AWS to update a stack, CloudFormation does a diff between the new template and the previously used template.  It only updates those resources where a property has changed.  When you update a Service Catalog product defined by a template file, if the name of the template is not changed, CloudFormation will not update the template.  

The ```upload-product-template.py``` script, calculates the checksum of the contents of the template and compares it to the previously created version.  If the contents of the file has changed, it uploads the template and gives it a new name.  The output of the script is the S3 key of the file that was uploaded.  It is passed to the CloudFormation template that creates or updates the product.

```bash

export ProductUrl=$(python3 $ScriptsDir/upload-product-template.py --file-name "$ProductTemplate.tmp" --bucket-name $CF_OUT_SourceBucket --should-version true)


echo $Parameters
sam deploy  --template-file  components/service-catalog-products/service-catalog-product.yml \
                        --stack-name $StackName \
                        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
                        --resolve-s3 \
                        --no-fail-on-empty-changeset \
                        --parameter-overrides ProductUrl=$ProductUrl
```