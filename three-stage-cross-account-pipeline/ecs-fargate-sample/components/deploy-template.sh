Template=$1
echo "Processing $Template"

set -e
# if [ -z $Template ]; then
#   echo "Template is $Template"
# else
#    echo "Template is required in deploy-template.sh"
#    exit -1
# fi

echo "Replacing variables in $TagFile"
python3 $ScriptsDir/replace-environment-vars.py \
                --json-file $TagFile > replaced-vars-tag.tmp


export Tags=$(python3 $ScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-vars-tag.tmp --key-value-type tags)

Tags="$Tags DeployedOn=$(date +'%d-%m-%Y %H:%M')"



jsonfilepath="$(dirname $Template)/$(basename "$Template" .yml).json"
echo "File"  $jsonfilepath
if test -f $jsonfilepath; then


        echo "Deploying $Template with parameters"
        cfn-include ${Template} > ./template.yaml -y
        echo "deploy-template:Replacing environment variables in"
        python3 $ScriptsDir/replace-environment-vars.py \
                        --json-file $jsonfilepath > replaced-vars.tmp

        export Parameters=$(python3 $ScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-vars.tmp --key-value-type parameters)

        export StackName=$(jq -r  '.Configuration[] | select(.Key == "StackName").Value' replaced-vars.tmp)
        echo "StackName=$StackName"
        if [ -v StackName ];
        then
           echo "Deploying $StackName"
        else
           export StackName=$(basename ${Template} ".yml") 
           echo "Deploying $StackName based on the template filename"
        fi

        echo  "Parameters -- $Parameters"
        sam deploy  --template-file  ./template.yaml  \
        --stack-name $StackName \
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
