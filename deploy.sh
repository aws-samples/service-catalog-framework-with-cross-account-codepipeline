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

export PortfolioStackName="service-catalog-portfolio-codepipeline"
echo "Deploying Service Catalog Portfolio"
cd components/service-catalog-portfolios 
# We could use a separate tag file here to configure the Tag Options for the portfolio
bash deploy.sh $TagFile
cd $BASEDIR


export FrameworkScriptsDir="$BASEDIR/scripts"


bash deploy-repository-products.sh