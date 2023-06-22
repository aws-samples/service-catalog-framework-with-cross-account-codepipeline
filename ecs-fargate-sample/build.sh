set -e

# Set the environment variables using the source command
source fargate-envs.sh

# set environment variables

export BASEDIR=$(pwd)
export TagFile=$(pwd)/configuration/tag-options.json

# build the application
cd docker-rest-api
mvn clean package

# If this is running on an ARM based Mac, use buildx to build an x86 container
# The Buildx command below has not been tested on x86 based Macs.
export OS=$(uname -s)
if [ $OS == "Darwin" ]
then
    echo "Creating an x86 container"
    docker buildx build --platform linux/amd64 -t $ContainerName .
else
    docker build -t $ContainerName .
fi