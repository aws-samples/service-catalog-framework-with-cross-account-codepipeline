#Exports tags from the current CodeBuild environment to bash environment variables
#It must be run using the "source" command

project_name=$(echo $CODEBUILD_BUILD_ARN | awk -F ":" '{split($6,a,"/"); print a[2]}')
echo $project_name
CurrentAccount=$(aws sts get-caller-identity  | jq -r ".Account") 
ARN="arn:aws:codebuild:$AWS_REGION:$CurrentAccount:project/$project_name"
# Get the tags of the environment
echo $ARN
aws resourcegroupstaggingapi get-resources --resource-arn-list "$ARN" --query 'ResourceTagMappingList[].Tags[].[Key,Value]' --output text
TAGS=$(aws resourcegroupstaggingapi get-resources --resource-arn-list "$ARN" --query 'ResourceTagMappingList[].Tags[].[Key,Value]' --output text)
# Set the equivalent environment variables
echo $TAGS
while read -r key value; do 
    export "$key"="$value" 
    echo "$key=$value" 
done <<< "$TAGS"
