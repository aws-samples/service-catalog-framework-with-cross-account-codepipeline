set -e

if ls ./*.yml 1> /dev/null 2>&1; then
 echo "files found";
else
   exit 0
fi

echo "7"
export $(aws cloudformation describe-stacks  --stack-name aws-sam-cli-managed-default --output text --query 'Stacks[0].Outputs[].join(`=`, [join(`_`, [`CF`, `OUT`, OutputKey]), OutputValue ])') 

for filename in ./*.yml; do \
        echo "bash ../deploy-template.sh ${filename}"
        pwd
        bash ../deploy-template.sh ${filename}
    done
#!/bin/bash



