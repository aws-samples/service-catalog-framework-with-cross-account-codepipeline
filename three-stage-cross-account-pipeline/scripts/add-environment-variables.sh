#!/bin/bash

set -e



while getopts ":t:m:p:o:" opt; do
  case ${opt} in
    t )
      tag_file=$OPTARG
      ;;
    m )
      main_template=$OPTARG
      ;;
    p )
      portfolio_id=$OPTARG
      ;;
    o )
      output_file=$OPTARG
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done





python3 $FrameworkScriptsDir/replace-environment-vars.py --json-file $tag_file > replaced-vars-aev.tmp

export templates=$(python3 $FrameworkScriptsDir/get-nested-templates.py --template-file $main_template -r CodeBuildIntegrationProject -r CodeBuildDeploymentProject --print-full-paths )

updated_template=$(dirname $main_template)"/main-template-with-parameters.tmp"
updated_template_with_codebuild_vars=$(dirname $main_template)"/main-template-with-cb-parameters.tmp"
python3 $ScriptsDir/add-parameters-to-template.py --config-file replaced-vars-aev.tmp --template-file $main_template  > "temp.yml.tmp"
python3 $ScriptsDir/add-parameters-to-nested-templates.py --config-file replaced-vars-aev.tmp --template-file temp.yml.tmp -r CodeBuildDeploymentProject -r CodeBuildIntegrationProject   > $updated_template_with_codebuild_vars


# Set the path to a temporary JSON file
json_main_template=$(pwd)/$(basename $main_template .yml).json.tmp

# Convert the CloudFormation main template to JSON format
cfn-flip -j $updated_template_with_codebuild_vars > $json_main_template

# Loop through each nested template file path, adding parameters and updating the main template if necessary
for path in $(echo $templates); do
    # Set the path for the updated nested template file
    updated_template=$path.nested.tmp

    # Run a Python script to add parameters to the nested template file
    python3 $ScriptsDir/add-parameters-to-template.py --config-file replaced-vars-aev.tmp --template-file $path > "temp.yml.tmp"
    python3 $ScriptsDir/add-env-vars-to-codebuild.py --template-file temp.yml.tmp > $updated_template

    # Loop through each resource in the main template and replace the TemplateURL with the updated nested template URL if the resource is a CloudFormation stack
    for resource in $(jq -r '.Resources | keys[]' $json_main_template); do
        resource_type=$(jq -r ".Resources.$resource.Type" $json_main_template)
        if [[ "$resource_type" == "AWS::CloudFormation::Stack" ]]; then
            echo "3"
            # The referenced templates are relative to the main template.  Calucalate the "relativity"/ 
            pushd $(dirname $main_template)
            relative_path=$(realpath --relative-to $(dirname $main_template) $path)
            echo "Main Template $(dirname $main_template)"
            echo "Relative Path $relative_path"
            popd


            jq ".Resources.$resource.Properties.TemplateURL |= if . == \"$relative_path\" then \"$updated_template\" else . end" $json_main_template > template.tmp
            mv template.tmp  $json_main_template

            relative_path="./$relative_path"

            jq ".Resources.$resource.Properties.TemplateURL |= if . == \"$relative_path\" then \"$updated_template\" else . end" $json_main_template > template.tmp
            mv template.tmp  $json_main_template
        fi
    done
done

# Convert the updated main template to YAML format
cfn-flip -y $json_main_template > $output_file

echo "File Created: $output_file"
