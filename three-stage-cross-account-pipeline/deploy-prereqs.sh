

bash deploy.sh service-catalog-codepipeline main
# Deploy shared resources across pipelines

set -e



pwd
export TagFile=$BASEDIR/configuration/tag-options.json
export TargetAccount=$(aws sts get-caller-identity  | jq -r ".Account") 
export Repository=service-catalog-codepipeline 
export Branch="main"

pushd components/lambdas
bash deploy.sh
popd

pushd components/s3
bash deploy.sh
popd

pushd components/roles
bash deploy.sh
popd







