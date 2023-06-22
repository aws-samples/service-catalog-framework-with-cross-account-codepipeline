# Build and deploy lambdas. This will automatically build 
# any Lambda based on a template in the ./custom-resources/template

set -e

if ls ./*.yml 1> /dev/null 2>&1; then
   exit 0
fi



for dir in  */; do \
        templates="$dir""*.yml"
        if ls $templates 1> /dev/null 2>&1; then
           echo "Processing directory: $dir";
        else
           echo "No template files found in the $dir directory. SKIPPING...."
           continue
        fi
        for template in $templates; do
            echo "bash ../deploy-template.sh ${template}"
            pwd
            bash deploy-template.sh ${template}
        done
done
