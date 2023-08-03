# Enabling sharing Service Catalog Products accounts

<TODO>: Explanation

##

<TODO Diagram>


## Deployment 

<TODO Explain Stacksets>

<TODO Diagram events>

### Prerequisites

<TODO Walkthrough of template to deploy to hub accounts to support Stacksets>


### Hub account deployment

```bash
export FrameworkScriptsDir=$(pwd)/scripts
export TagFiles=$(pwd)/configuration/tag-options.json
cd components/shared-products-resources

bash deploy.sh --spoke-accounts <comma separated list of spoke accounts> --regions <comma separated list of regions to deploy to> --devops-account $(aws sts get-caller-identity  | jq -r ".Account")
```

## References

https://github.com/aws-samples/aws-service-catalog-auto-import

