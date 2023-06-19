import cfnresponse as cfnresponse
import boto3
import json
import argparse

def find_roles_by_policy(policy_names):
    # create an IAM client
    iam = boto3.client('iam')
    matched_roles = []

    # create a paginator for the list_roles operation
    paginator = iam.get_paginator('list_roles')

    # iterate through the paginator to retrieve all roles
    for page in paginator.paginate():
        roles = page["Roles"]
        # iterate through the roles and check if they have the specified policy attached
        for role in roles:
            policies = iam.list_attached_role_policies(RoleName=role['RoleName'])['AttachedPolicies']
            for policy in policies:
                if policy['PolicyName'] in policy_names:
                    matched_roles.append(role['Arn'])
    return matched_roles

def associate_roles_to_portfolio(portfolio_id, role_arns):
    # create a Service Catalog client
    sc = boto3.client('servicecatalog')

    # associate each role with the specified portfolio
    for role_arn in role_arns:
        try:
            sc.associate_principal_with_portfolio(
                PortfolioId=portfolio_id,
                PrincipalARN=role_arn,
                PrincipalType='IAM'
            )
        except Exception as e:
            # if the role is already associated with the portfolio, skip the error
            if 'already associated' not in str(e).lower():
                raise


def delete_portfolio_roles(portfolio_id):
    """
    Delete all roles associated with an AWS Service Catalog Portfolio.
    """
    sc_client = boto3.client('servicecatalog')

    # Get the list of IAM roles associated with the portfolio
    response = sc_client.list_principals_for_portfolio(PortfolioId=portfolio_id)
    role_arns = [r['PrincipalARN'] for r in response['Principals']]
    print(response)
    # Detach each IAM role from the portfolio
    for arn in role_arns:
        print(f"Removing {arn} from portfolio")
        sc_client.disassociate_principal_from_portfolio(PortfolioId=portfolio_id, PrincipalARN=arn)



def lambda_handler(event, context):
    print(json.dumps(event))
    props = event['ResourceProperties']
    try:
        # validate the required properties
        required_props = ['PolicyNames', 'PortfolioId']
        for prop in required_props:
            if prop not in props:
                raise ValueError(f"Missing required property: {prop}")
        
        portfolio_id = props['PortfolioId']

        if event['RequestType'] == 'Delete':
            print("removing roles from portfolio")
            delete_portfolio_roles(portfolio_id)
            cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
            return
        
        # find roles with the specified policies attached
        policy_names = props['PolicyNames']
        role_arns = find_roles_by_policy(policy_names)

        # associate the roles with the specified portfolio
        associate_roles_to_portfolio(portfolio_id, role_arns)

        # send a success response
        cfnresponse.send(event, context, cfnresponse.SUCCESS,{}, portfolio_id)

    except Exception as e:
        # send a failure response with the error message
        print(e)
        cfnresponse.send(event, context, cfnresponse.FAILED, {}, reason=str(e))
