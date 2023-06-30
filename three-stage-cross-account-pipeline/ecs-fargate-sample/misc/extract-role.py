import argparse
import boto3
import json
import yaml

def create_cloudformation_template(role_name, output_file):
    resource_name = role_name.replace("-","")
    # Initialize Boto3 clients for IAM and CloudFormation
    iam_client = boto3.client('iam')

    # Get the IAM role details
    role_response = iam_client.get_role(RoleName=role_name)
    role = role_response['Role']

    # Create the CloudFormation template dictionary
    template = {
        'AWSTemplateFormatVersion': '2010-09-09',
        'Resources': {
            resource_name: {
                'Type': 'AWS::IAM::Role',
                'Properties': {
                    'AssumeRolePolicyDocument': {
                        'Statement': [
                            {
                                'Effect': 'Allow',
                                'Principal': {
                                    'Service': ['ec2.amazonaws.com']
                                },
                                'Action': ['sts:AssumeRole']
                            }
                        ]
                    },
                    'Path': '/',
                    'ManagedPolicyArns': []
                }
            }
        }
    }

    # Get the attached ManagedPolicies for the role
    attached_policies_response = iam_client.list_attached_role_policies(RoleName=role_name)
    attached_policies = attached_policies_response['AttachedPolicies']

    # Add ManagedPolicies to the template
    for policy in attached_policies:
        template['Resources'][resource_name]['Properties']['ManagedPolicyArns'].append(policy['PolicyArn'])

    # Get the inline policies for the role
    inline_policies_response = iam_client.list_role_policies(RoleName=role_name)
    inline_policies = inline_policies_response['PolicyNames']

    # Add inline policies to the template
    for policy_name in inline_policies:
        policy_response = iam_client.get_role_policy(RoleName=role_name, PolicyName=policy_name)
        policy_document = policy_response['PolicyDocument']
        template['Resources'][f'{resource_name}Policy{policy_name}'] = {
            'Type': 'AWS::IAM::Policy',
            'Properties': {
                'PolicyName': f'{resource_name}Policy{policy_name}',
                'PolicyDocument': policy_document,
                'Roles': [{'Ref': resource_name}]
            }
        }

    # Write the template to a file
    with open(output_file, 'w') as f:
        f.write(yaml.dump(template))

    print(f"CloudFormation template created successfully: {output_file}")

if __name__ == '__main__':
    # Create the argument parser
    parser = argparse.ArgumentParser(description='Create a CloudFormation template for an AWS IAM role')

    # Add the role name argument
    parser.add_argument('role_name', type=str, help='Name of the IAM role')

    # Add the output file argument
    parser.add_argument('output_file', type=str, help='Output file path for the CloudFormation template')

    # Parse the arguments
    args = parser.parse_args()

    # Create the CloudFormation template
    create_cloudformation_template(args.role_name, args.output_file)
