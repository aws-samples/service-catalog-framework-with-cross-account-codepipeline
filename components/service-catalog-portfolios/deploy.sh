set -e

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag-options-file)
            TagOptionsFile="$2"
            shift 2
            ;;
        --parameters-file)
            ParametersFile="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

rm service-catalog-portfolio.yml.tmp || true


if [ -v TagOptionsFile ]; then
  python3 $FrameworkScriptsDir/replace-environment-vars.py \
                    --json-file $TagOptionsFile > replaced-tag-options-vars.tmp

  python3 $FrameworkScriptsDir/create-tag-options.py \
    --config-file replaced-tag-options-vars.tmp \
    --template-file  ./service-catalog-portfolio.yml > service-catalog-portfolio.yml.tmp
else
  cp ./service-catalog-portfolio.yml service-catalog-portfolio.yml.tmp
fi

python3 $FrameworkScriptsDir/replace-environment-vars.py \
                    --json-file $ParametersFile > replaced-vars.tmp

export Parameters=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-vars.tmp --key-value-type parameters)


sam deploy  --template-file  service-catalog-portfolio.yml.tmp \
                        --stack-name $PortfolioStackName \
                        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
                        --resolve-s3 \
                        --parameter-overrides Nonce=$RANDOM "$Parameters" \
                        --no-fail-on-empty-changeset 


