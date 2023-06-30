import argparse
import yaml
import json
from cfn_flip import flip, to_yaml, to_json

# Parse the command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--config-file', help='The configuration file',required=True)
parser.add_argument('--template-file', help='The CloudFormation template file',required=True)
args = parser.parse_args()

# Load the configuration file
with open(args.config_file, 'r') as f:
    config = json.load(f)


# Load the existing CloudFormation template
with open(args.template_file, 'r') as f:
    jsonTemplate=to_json(f.read())
    template = json.loads(jsonTemplate)

# Check if the 'Parameters' section already exists in the template
if 'Parameters' not in template:
    template['Parameters'] = {}

# Check if the 'Metadata' section already exists in the template
if 'Metadata' not in template:
    template['Metadata'] = {}

# Check if the 'AWS::CloudFormation::Interface' section already exists in the metadata section
if 'AWS::CloudFormation::Interface' not in template['Metadata']:
    template['Metadata']['AWS::CloudFormation::Interface'] = {}

# Check if the 'ParameterGroups' section already exists in the AWS::CloudFormation::Interface section
if 'ParameterGroups' not in template['Metadata']['AWS::CloudFormation::Interface']:
    template['Metadata']['AWS::CloudFormation::Interface']['ParameterGroups'] = []

default_parameter_group = config.get('DefaultParameterGroup', '')

# Loop through the configuration and add the parameters to the template
for param in config['Configuration']:
    # Create a dictionary for the parameter
    if not param.get('Default') and not param.get('Value'):
        raise ValueError(f"No default or value specified for parameter '{param['Key']}'")
    
    param_dict = {
        'Type': 'String',
        'Default': param.get('Default', ''),
        'Description': param.get('Description', '')
    }
    if param.get('Value'):
        param_dict['Default'] = param['Value']

    # If the parameter has allowed values, add them to the dictionary
    if 'AllowedValues' in param:
        param_dict['AllowedValues'] = param['AllowedValues']

    # If the parameter has a ParameterGroup, add it to the template
    if 'ParameterGroup' in param:
        label = param['ParameterGroup']
    else:
        label = default_parameter_group

    # Add the parameter to the template
    template['Parameters'][param['Key']] = param_dict

    # Check if the parameter group should be added to the metadata section
    if label:
        pg_sort_order = config.get('ParameterGroupSortOrder', [])
        if label in pg_sort_order:
            # Add the parameter group to the AWS::CloudFormation::Interface section
            pg_found = False
            for pg_dict in template['Metadata']['AWS::CloudFormation::Interface']['ParameterGroups']:
                if pg_dict.get('Label') == label:
                    pg_dict.setdefault('Parameters', []).append(param['Key'])
                    pg_found = True
                    break
            if not pg_found:
                template['Metadata']['AWS::CloudFormation::Interface']['ParameterGroups'].append({'Label': label, 'Parameters': [param['Key']]})

print(yaml.dump(template))
