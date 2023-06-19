export Repository=$1 
export Branch=$2

set -e

sam package -t cross-account-codepipeline.yml \
    --output-template-file cross-account-codepipeline.tmp \
    --resolve-s3 

sam deploy --stack-name cross-account-codepipeline \
           --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM \
           --resolve-s3  \
           --template-file cross-account-codepipeline.tmp\
           --parameter-overrides Repository=$Repository Branch=$Branch DeploymentBuildSpec=buildspec.yml IntegrationBuildSpec=buildspec-integration.yml \
            --no-fail-on-empty-changeset 