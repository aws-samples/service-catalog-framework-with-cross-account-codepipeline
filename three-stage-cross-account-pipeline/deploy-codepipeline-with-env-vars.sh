set -e

export ProductName="CodePipeline with tag support"
export ProductDescription="Three Stage Pipeline with added environment variables"
export ProvisioningArtifactDescriptionParameter=$ProductDescription
export Nonce=$RANDOM
export TargetAccount=$(aws sts get-caller-identity  | jq -r ".Account")
export Repository="cross-account-pipeline-v2"
export Branch="main"
export FrameworkScriptsDir=$BASEDIR/scripts
bash $ScriptsDir/add-environment-variables.sh \
    $BASEDIR/three-stage-cross-account-pipeline/tags.json \
    $BASEDIR/three-stage-cross-account-pipeline/cross-account-codepipeline.yml 

pwd
echo "BASEDIR=$BASEDIR"


bash deploy-service-catalog-product.sh \
     $BASEDIR/three-stage-cross-account-pipeline/cross-account-codepipeline-processed.yml\
     $BASEDIR/three-stage-cross-account-pipeline/cross-account-codepipeline.json\
     codepipeline-with-tag-support