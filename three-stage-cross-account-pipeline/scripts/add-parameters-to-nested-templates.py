import argparse
import json
from cfn_flip import flip, to_yaml, to_json
import yaml


parser = argparse.ArgumentParser(description='Modify AWS::CloudFormation::Stack resources in a CloudFormation template file.')
parser.add_argument('--template-file', '-t', required=True, help='path to the CloudFormation template file in YAML format')
parser.add_argument('--config-file', '-c', required=True, help='path to the configuration file in JSON format')
parser.add_argument('-r', '--resource', required=True, action='append', help='name of an AWS::CloudFormation::Stack resource to modify')
args = parser.parse_args()


def update_nested_stack_parameters(cfn_template_file, stack_names, config_file):
    with open(cfn_template_file, 'r') as f:
        cfn_template = json.loads(flip(f.read()))
    
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Modify the AWS::CloudFormation::Stack resources with the given names
    for stack_name in stack_names:
        resource = cfn_template['Resources'].get(stack_name)
        if resource and resource.get('Type') == 'AWS::CloudFormation::Stack':
            existing_params = resource['Properties'].get('Parameters', {})
            # Create nested stack parameters from config file
            nested_stack_params = existing_params.copy()
            for item in config['Configuration']:
                if item['Key'] in existing_params:
                    nested_stack_params[item['Key']] = {"Ref": item['Key']}
            resource['Properties']['Parameters'] = nested_stack_params
    
    # Write the modified template to a new file
    print(yaml.dump(cfn_template))


cfn_template_file = args.template_file
stack_names = args.resource
config_file = args.config_file

update_nested_stack_parameters(cfn_template_file, stack_names, config_file)
