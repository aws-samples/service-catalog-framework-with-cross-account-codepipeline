set -e

export S3Bucket="$1"
export SourceDirectory="$2"
export ApplicationName="$3"
export DeploymentGroup="$4"

echo "S3Bucket=$S3Bucket"
echo "Source Directory=$2"
ls $SourceDirectory

bash $ScriptsDir/zip-file.sh $(pwd)/artifacts.zip $SourceDirectory


# The upload-file-with-hash script appends a hash of the contents of the file
# to the filename making it unique.
# We need the same functionality to ensure that the CodeDeploy Artifact is unique.

export S3Key=$(python3 "$FrameworkScriptsDir/upload-file-with-hash.py" --file-name "artifacts.zip" --bucket-name $S3Bucket  --should-version true)

echo "ArtifactUrl=$ArtifactUrl"

# Replace the HTTPS URL with your own URL
# Extract the S3 bucket name and object key from the HTTPS URL
# Remove the ".s3.amazonaws.com" portion from the bucket name
echo "Artifact Location: Bucket:$S3Bucket  Key:$S3Key"
# Generate the S3 URL
s3_url="s3://$S3Bucket/$S3Key"

aws s3 cp artifacts.zip $s3_url


deployment_id=$(aws deploy create-deployment --application-name $ApplicationName \
  --deployment-group-name $DeploymentGroup \
  --s3-location bucket=$S3Bucket,bundleType=zip,key=$S3Key \
  --query "deploymentId" --output text)

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