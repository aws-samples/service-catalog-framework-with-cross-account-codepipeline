import argparse
import time

import boto3

parser = argparse.ArgumentParser(description='Deploys an Amazon CloudFormation.')
parser.add_argument('--stackset-name', required=True)
parser.add_argument('--template-body', required=True)
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--organizational-units', help='Comma-separated list of Organizational Unit IDs')
group.add_argument('--accounts', help='Comma-separated list of AWS account IDs')
parser.add_argument('--regions', required=True)
parser.add_argument("-p", "--parameter", nargs="+", required=False, action='append')

args = parser.parse_args()

print(args)

client = boto3.client('cloudformation')

with open(args.template_body) as f:
    template_body = f.read()

def get_stackset_caller():
    try:

        sts_client = boto3.client("sts")
        identity = sts_client.get_caller_identity()
        account_number = identity["Account"]

        organization_client = boto3.client('organizations')
        organization = organization_client.describe_organization()["Organization"]
        organization_account = organization["MasterAccountId"]

        return  "SELF_MANAGED" if account_number == organization_account else "DELEGATED_ADMIN"
    except Exception as  exception:
        print(str(exception))
        print("Warning: Could not determine if running in an organization account ")
        print("         Defaulting to SELF ")
        # Default to SELF if any error occurs
        return "SELF_MANAGED"


def wait_for_stackset_complete(stackset_name, operation_id):
    while True:
        response = client.describe_stack_set_operation(
            StackSetName=stackset_name,
            OperationId=operation_id
        )
        status = response["StackSetOperation"]["Status"]
        if status in ["RUNNING", "QUEUED"]:
            print(f"StackSet {stackset_name} Status {status}")
            time.sleep(5)
        elif status == "SUCCEEDED":
            print(status)
            break
        elif status == "FAILED":
            print(response)
            raise Exception(f"StackSet {stackset_name} FAILED. OperationId: {operation_id}")
        else:
            print(status)
            break

paginator = client.get_paginator("list_stack_sets")

stack_set_exists = False

for page in paginator.paginate(Status="ACTIVE"):
    if len(list(filter(lambda stack_set: stack_set["StackSetName"] == args.stackset_name, page["Summaries"]))):
        stack_set_exists = True
        break

stack_parameters = []
if args.parameter is not None: 
    for parameter in args.parameter:
        stack_parameters.append({
            "ParameterKey": parameter[0].split("=")[0],
            "ParameterValue": parameter[0].split("=")[1]
        })

stack_set_id = ""
if not stack_set_exists:
    stack_set_id = client.create_stack_set(
        StackSetName=args.stackset_name,
        TemplateBody=template_body,
        Capabilities=["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"],
        Parameters=stack_parameters
    )

# You cannot update a template and other properties in one call.
print(f"Updating template for Stackset {args.stackset_name}")
operation_id = client.update_stack_set(
    StackSetName=args.stackset_name,
    TemplateBody=template_body,
    Parameters=stack_parameters,
    Capabilities=["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
)["OperationId"]

wait_for_stackset_complete(args.stackset_name, operation_id)

if args.organizational_units is not None:
    deployment_targets = {"OrganizationalUnitIds": args.organizational_units.split(",")}
elif args.accounts is not None:
    deployment_targets = {"Accounts": args.accounts.split(",")}
else:
    raise ValueError("Please specify either --organizational_units or --accounts")

print(f"Deploying to deployment targets: {deployment_targets} for Stackset {args.stackset_name}")
print(f"Deploying to regions:           {args.regions.split(',')}")
client.create_stack_instances(
    StackSetName=args.stackset_name,
    DeploymentTargets=deployment_targets,
    Regions=args.regions.split(",")
)


wait_for_stackset_complete(args.stackset_name, operation_id)

