set -e
export BASEDIR=$(pwd)

if [[ -z "$FrameworkScriptsDir" ]]; then
    export FrameworkScriptsDir="$BASEDIR/scripts"
fi

export TagFile=$BASEDIR/configuration/tag-options.json


echo "Deploying Lambdas"
cd components/lambdas
bash deploy.sh 
cd $BASEDIR

export PortfolioStackName="service-catalog-portfolio-admin"
echo "Deploying Service Catalog Portfolio"
cd components/service-catalog-portfolios 
bash deploy.sh --tag-options-file $TagFile --parameters-file $BASEDIR/portfolio-admin-config.json
export PortfolioStackName="service-catalog-portfolio-enduser"
bash deploy.sh --parameters-file $BASEDIR/portfolio-enduser-config.json


cd $BASEDIR


export FrameworkScriptsDir="$BASEDIR/scripts"


bash deploy-repository-products.sh

# Deploy resources needed to automated sharing portfolios

cd components/shared-products-resources
bash deploy.sh --spoke-accounts $SpokeAccounts \
               --devops-account $(aws sts get-caller-identity  | jq -r ".Account") \
               --regions us-east-1

cd ..

