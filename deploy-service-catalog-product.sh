


set -e


export VersionDescription="Built on $(date)"
export ProductTemplate=$1
export ConfigFile=$2
export StackName="$3"
export Nonce=$RANDOM

echo "3"
export $(aws cloudformation describe-stacks  --stack-name $PortfolioStackName --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])')


if [ -v ProductTemplate ]; then
  echo "ProductTemplate is $ProductTemplate"
else
   echo "ProductTemplate is required in deploy-service-catalog-product"
   exit -1
fi

if [ -v ConfigFile ]; then
  echo "ConfigFile is $ConfigFile"
else
   echo "ConfigFile is required in deploy-service-catalog-product"
   exit -1
fi

if [ -v ProductTemplate ]; then
  echo "ProductTemplate is $ProductTemplate"
else
   echo "ProductTemplate is required in deploy-service-catalog-product"
   exit -1
fi


if [ -v StackName ]; then
  echo "StackName is $StackName"
else
   echo "StackName is required in deploy-service-catalog-product"
   exit -1
fi

export ScriptsDir=$BASEDIR/$(dirname $ProductTemplate)/scripts
echo "ScriptsDir - $ScriptsDir"


if [ -v ProductTemplate ]; then
  echo "ProductTemplate is $ProductTemplate"
else
   echo "ProductTemplate is required in deploy-service-catalog-product"
   exit -1
fi

if [[ -z "$FrameworkScriptsDir" ]]; then
    export FrameworkScriptsDir="$(pwd)/scripts"
fi



set -e

# Some Products require a common set of resources. 
# This script looks for a shell script in the product directory - deploy-prereqs.sh
# and runs that first if present.
export PreReqBashFile="$(dirname $ProductTemplate)/deploy-prereqs.sh"
echo "Looking for $PreReqBashFile"


if [ -f $PreReqBashFile ]; then
    echo "Deploying Prerequisites"
    pushd $(dirname $ProductTemplate)
    bash $(basename $PreReqBashFile)
    popd
else
    echo "$PreReqBashFile not found. SKIPPING..."
fi

sam package -t $ProductTemplate \
    --output-template-file "$ProductTemplate.tmp" \
    --resolve-s3
echo "4"
export $(aws cloudformation describe-stacks  --stack-name aws-sam-cli-managed-default --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])')
export ProductUrl=$(python3 $FrameworkScriptsDir/upload-product-template.py --file-name "$ProductTemplate.tmp" --bucket-name $CF_OUT_SourceBucket --should-version true)



echo "S3 Url $ProductUrl"
echo "5"
export $(aws cloudformation describe-stacks  --stack-name $PortfolioStackName --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])')

echo "Replacing environment variables in deploy-service-catalog-product"
python3 $FrameworkScriptsDir/replace-environment-vars.py \
                    --json-file $ConfigFile > replaced-product-vars.tmp

export Parameters=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-product-vars.tmp --key-value-type parameters)

export Tags=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-product-vars.tmp --key-value-type tags)

echo "$0($LINENO):Replacing environment variables in tag options file"

echo $Parameters
echo "Current directory $(pwd)"
sam deploy  --template-file  components/service-catalog-products/service-catalog-product.yml \
                        --stack-name $StackName \
                        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
                        --resolve-s3 \
                        --no-fail-on-empty-changeset \
                        --parameter-overrides "$Parameters" \
                        --tags "$Tags"
