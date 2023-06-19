# Build and deploy lambdas. This will automatically build 
# any Lambda based on a template in the ./custom-resources/template

set -e

if ls ./*.yml 1> /dev/null 2>&1; then
   exit 0
fi


export SupressionFile=$1

for dir in  */; do \
        echo "Processing directory: $dir";
        templates="$dir""*.yml"
        for template in $templates; do
                echo "Processing template: $template";
                bandit -r $dir/src

                if [ -n "${CODEBUILD_BUILD_ID+x}" ] || [[ "${AWS_EXECUTION_ENV}" == *"CloudShell"* ]]; then
                        sam build -t $template
                else
                        sam build -t $template --use-container;
                fi

                sam package -t .aws-sam/build/template.yaml \
                        --output-template-file template.tmp \
                        --resolve-s3
                sam validate --template-file template.tmp  --lint

                bandit -r $dir/src
                                
                cfn_nag_scan \
                        --deny-list-path $SupressionFile \
                        --input-path .aws-sam/build/template.yaml  > warnings.txt


                num_warnings=$(grep -o 'Warnings count: [0-9]*' "warnings.txt" | grep -o '[0-9]*')

                if [[ $num_warnings -ne 0 ]]; then
                        echo "Error: There are $num_warnings warnings in $dir"
                        cat warnings.txt
                        exit 1
                fi
        done
done

