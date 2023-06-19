# Build and deploy lambdas. This will automatically build 
# any Lambda based on a template in the ./custom-resources/template

set -e

if ls ./*.yml 1> /dev/null 2>&1; then
   exit 0
fi


export SupressionFile=$1

for dir in  */; do \
        templates="$dir""*.yml"
        if ls $templates 1> /dev/null 2>&1; then
           echo "Processing directory: $dir";
        else
           echo "No template files found in the $dir directory. SKIPPING...."
           continue
        fi
        for template in $templates; do
                echo "Processing template: $template";
                sam validate --template-file $template  --lint
                set +e
                cfn_nag_scan \
                        --deny-list-path $SupressionFile \
                        --input-path $template  > warnings.txt

                num_warnings=$(grep -o 'Warnings count: [0-9]*' "warnings.txt" | grep -o '[0-9]*')

                if [[ $num_warnings -ne 0 ]]; then
                        echo "Error: There are $num_warnings warnings in $dir"
                        cat warnings.txt
                        exit 1
                fi
                set -e
        done
done

