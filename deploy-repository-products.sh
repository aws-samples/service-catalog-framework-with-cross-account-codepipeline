
set -e
echo "1"
export $(aws cloudformation describe-stacks  --stack-name $PortfolioStackName --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])')

echo "2"
export $(aws cloudformation describe-stacks  --stack-name $PortfolioStackName --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])')

export ScriptsDir=$BASEDIR/three-stage-cross-account-pipeline/scripts

bash $ScriptsDir/add-environment-variables.sh \
    -t "$BASEDIR/configuration/tag-options.json" \
    -m $BASEDIR"/three-stage-cross-account-pipeline/cross-account-codepipeline.yml"  \
    -p $CF_OUT_ServiceCatalogPortfolio \
    -o $BASEDIR"/three-stage-cross-account-pipeline/cross-account-pipeline-with-tags.yml.tmp"

export ServiceCatalogRoleName=$CF_OUT_ServiceCatalogCloudFormationRole

bash deploy-service-catalog-product.sh \
     $BASEDIR"/three-stage-cross-account-pipeline/cross-account-pipeline-with-tags.yml.tmp" \
     $BASEDIR/three-stage-cross-account-pipeline/cross-account-codepipeline.json \
      three-stage-pipeline 


