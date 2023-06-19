# Build and deploy lambdas. This will automatically build 
# any Lambda based on a template in the ./custom-resources/template

set -e

# If no directories are found, exit.
if ls ./*.yml 1> /dev/null 2>&1; then
   exit 0
fi



export Nonce=$RANDOM
for dir in  */; do \
        echo "Processing directory: $dir";
        templates="$dir""*.yml"
        for template in $templates; do
           bash ./deploy-lambda.sh $dir $template $TagFile
        done
done

