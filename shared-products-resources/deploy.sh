#!/bin/bash

# Set default values for parameters

set -e

SpokeAccounts=""
Regions=""
DevOpsAccount=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --spoke-accounts) export SpokeAccounts="$2"; shift ;;
        --regions) Regions="$2"; shift ;;
        --devops-account) export DevOpsAccount="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "Spoke Accounts=$SpokeAccounts"

if [ -z "$SpokeAccounts" ] || [ -z "$Regions" ] || [ -z "$DevOpsAccount" ]; then
    echo "Missing one or more required parameters."
    echo "Usage: ./deploy.sh --spoke-accounts <comma separated values> --regions <comma separated values> --devops-account <value>"
    exit 1
fi


export OLD_REGION=$AWS_DEFAULT_REGION
bash ../deploy-template.sh ./sc-sns-hub.yml

export AWS_DEFAULT_REGION=us-east-1
# We don't need this for SC
# bash ../deploy-template.sh ./cft-stackset-admin-role.yml

cfn-include ./stackset-sc-autopilot-setup.yml > ./template.yaml -y

python3 $FrameworkScriptsDir/deploy-stacksets.py \
    --template-body ./template.yaml \
    --account $SpokeAccounts \
    --regions $Regions \
    --stackset-name sc-autopilot-setup \
    -p DevOpsAccount=$DevOpsAccount 
python3 $FrameworkScriptsDir/deploy-stacksets.py \
    --template-body ./stackset-service-catalog-roles.yml \
    --account $SpokeAccounts \
    --stackset-name service-catalog-roles \
    --regions $Regions 
export AWS_DEFAULT_REGION=$OLD_REGION

