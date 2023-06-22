export Repository="$1"
export ContainerName="$2"

set -e


export AccountId=$(aws sts get-caller-identity  | jq -r ".Account") 


export Tag=$CODEBUILD_BUILD_NUMBER
if [ -z $Tag ]
then
    echo "Not running within CodeBuild. Using a Random tag"
    export Tag=$RANDOM
fi

# export Repository=acme

docker tag java-docker-poc $AccountId.dkr.ecr.$AWS_REGION.amazonaws.com/$Repository:$ContainerName-$Tag

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AccountId.dkr.ecr.$AWS_REGION.amazonaws.com

docker push $AccountId.dkr.ecr.$AWS_REGION.amazonaws.com/$Repository:$ContainerName-$Tag
echo "docker tag: $ContainerName-$Tag"

export FargateStackName=$ContainerName
export Image=$ContainerName-$Tag

pushd $BASEDIR/components
bash deploy.sh
popd