set -e

export TagOptionsFile="$1"



python3 $FrameworkScriptsDir/replace-environment-vars.py \
                    --json-file $TagOptionsFile > replaced-tag-options-vars.tmp

python3 $FrameworkScriptsDir/create-tag-options.py \
  --config-file replaced-tag-options-vars.tmp \
  --template-file  ./service-catalog-portfolio.yml > service-catalog-portfolio.yml.tmp



sam deploy  --template-file  service-catalog-portfolio.yml.tmp \
                        --stack-name $PortfolioStackName \
                        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
                        --resolve-s3 \
                        --parameter-overrides Nonce=$RANDOM \
                        --no-fail-on-empty-changeset 


