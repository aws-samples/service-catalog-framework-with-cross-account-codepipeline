export ProvisioningArtifactDescriptionParameter="Three Stage CodePipeline"
export VersionDescription="Built on $(date)"
export ProductTemplate=$1

if [ -v ProductTemplate ]; then
  echo "ProductTemplate is $ProductTemplate"
else
   echo "ProductTemplate is required in scan-service-catalog-product"
   exit -1
fi

shopt -s xpg_echo

#!/bin/bash

set -e

export ScriptsDir=$CODEBUILD_SRC_DIR/scripts
export Templates=$(python3 $ScriptsDir/get-nested-templates.py --template-file $ProductTemplate)


pushd $(dirname $ProductTemplate)
for path in $(echo $Templates); do
    sam validate --template-file "$path"  --lint
    # add cfn_nag
done
popd

sam package -t $ProductTemplate \
    --output-template-file "$ProductTemplate.tmp" \
    --resolve-s3

sam validate --template-file $ProductTemplate.tmp --lint