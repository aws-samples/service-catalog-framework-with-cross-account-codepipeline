
export $(aws cloudformation describe-stacks  --stack-name codedeploy-source-bucket --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])')
export S3Bucket=$CF_OUT_CodePipelineSourceBucket #Change this should be #CodeDeploySourceBucket

zip -u artifacts.zip ./SampleApp_Linux

# The upload-product-template script appends a hash of the contents of the file
# to the filename making it unique.
# We need the same functionality to ensure that the CodeDeploy Artifact is unique.

export ArtifactUrl=$(python3 $FrameworkScriptsDir/upload-product-template.py --file-name "artifacts.zip" --bucket-name $S3Bucket  --should-version true)

# Replace the HTTPS URL with your own URL
# Extract the S3 bucket name and object key from the HTTPS URL
bucket_name=$(echo "$ArtifactUrl" | awk -F/ '{print $3}')
object_key=$(echo "$ArtifactUrl" | awk -F/ '{$1=$2=$3=""; print substr($0, 4)}')
# Remove the ".s3.amazonaws.com" portion from the bucket name
bucket_name=${bucket_name%.s3.amazonaws.com}
echo "Artifact Location: Bucket:$bucket_name Key:$object_key"
# Generate the S3 URL
s3_url="s3://$bucket_name/$object_key"

aws s3 cp artifacts.zip $s3_url

export $(aws cloudformation describe-stacks  --stack-name codedeploy --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])')


deployment_id=$(aws deploy create-deployment --application-name $CF_OUT_CodeDeployApplication --deployment-group-name $CF_OUT_CodeDeployDeploymentGroup --s3-location bucket=$bucket_name,bundleType=zip,key=$object_key --query "deploymentId" --output text)

# Wait for the deployment to finish
while true; do
  deployment_status=$(aws deploy get-deployment --deployment-id $deployment_id --query "deploymentInfo.status" --output text)
  if [[ "$deployment_status" == "Succeeded" ]]; then
    echo "Deployment succeeded!"
    exit 0
  elif [[ "$deployment_status" == "Failed" ]]; then
    echo "Deployment failed!"
    exit 1
  fi
  echo $deployment_status
  sleep 10  # Wait for 10 seconds before checking the status again
done