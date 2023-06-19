Template=$1

set -e
if [ -z $Template ]; then
  echo "Template is $Template"
else
   echo "Template is required in deploy-lambda.sh"
   exit -1
fi

python3 $FrameworkScriptsDir/replace-environment-vars.py \
                --json-file $TagFile > replaced-vars-tag.tmp


export Tags=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-vars-tag.tmp --key-value-type tags)

Tags="$Tags DeployedOn=$(date +'%d-%m-%Y %H:%M')"



jsonfilepath="$(dirname $Template)/$(basename "$Template" .yml).json"
echo "File"  $jsonfilepath
if test -f $jsonfilepath; then
        echo "Deploying $Template with parameters"
        cfn-include ${Template} > ./template.yaml -y
        echo "deploy-template:Replacing environment variables in"
        python3 $FrameworkScriptsDir/replace-environment-vars.py \
                        --json-file $jsonfilepath > replaced-vars.tmp

        export Parameters=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-vars.tmp --key-value-type parameters)


        echo  "Parameters -- $Parameters"
        sam deploy  --template-file  ./template.yaml  \
        --stack-name $(basename ${Template} ".yml")  \
        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM \
        --parameter-overrides Nonce=$RANDOM  "$Parameters"\
        --tags "$Tags" \
        --resolve-s3 \
        --no-fail-on-empty-changeset
else
        echo "Deploying ${Template}"
        cfn-include ${Template} > ./template.yaml -y

        #if there is a corresponding json file, parse the file and create the parameter argument
        
        sam deploy  --template-file  ./template.yaml  \
        --stack-name $(basename ${Template} ".yml")  \
        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM \
        --parameter-overrides Nonce=$RANDOM \
        --resolve-s3 \
        --no-fail-on-empty-changeset \
        --tags "$Tags" 

fi
