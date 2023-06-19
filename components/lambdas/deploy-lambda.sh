# Use this to deploy a single Lambda
# Two arguments are required - the directory containing the template
# and the name of the template.

set -e
export TemplateDir=$1
export Template=$2

if [ -v TemplateDir ]; then
  echo "TemplateDir is $TemplateDir"
else
   echo "TemplateDir is required in deploy-lambda.sh"
   exit -1
fi

if [ -v Template ]; then
  echo "Template is $Template"
else
   echo "Template is required in deploy-lambda.sh"
   exit -1
fi

python3 $FrameworkScriptsDir/replace-environment-vars.py \
                                    --json-file $TagFile > replaced-vars-tag.tmp
export Tags=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-vars-tag.tmp --key-value-type tags)
echo "Tags=$Tags"
Tags="$Tags DeployedOn=$(date +'%d-%m-%Y %H:%M')"

# Look for a corresponding config file containing parameter names and values
jsonfilepath="$TemplateDir/$(basename "$Template" .yml).json"

echo "Processing template: $Template";
stackname=$(basename ${Template} ".yml");
# If not running within CodeBuild or Cloudshell,
# use Docker to build the Lambda with the correct runtime environment
if [ -n "${CODEBUILD_BUILD_ID+x}" ] || [[ "${AWS_EXECUTION_ENV}" == *"CloudShell"* ]]; then
    sam build -t $Template
else
    sam build -t $Template --use-container;
fi


echo "$(pwd)"
echo "Looking for $jsonfilepath"
if test -f $jsonfilepath; then
    echo "Deploying $template with parameters"
    cfn-include ${Template} > ./template.yaml -y
    echo "deploy-lambdas:Replacing environment variables in tag options file"
    python3 $FrameworkScriptsDir/replace-environment-vars.py \
                                    --json-file $jsonfilepath > replaced-vars.tmp

    export Parameters=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-vars.tmp --key-value-type parameters)

    sam deploy  --template-file  .aws-sam/build/template.yaml  --stack-name $stackname \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --resolve-s3 \
    --no-fail-on-empty-changeset \
    --parameter-overrides "$Parameters" \
    --tags "$Tags"

else

    sam deploy  --template-file  .aws-sam/build/template.yaml  --stack-name $stackname \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --resolve-s3 \
    --no-fail-on-empty-changeset \
    --tags "$Tags"

           
fi

echo  "Tags $Tags"
