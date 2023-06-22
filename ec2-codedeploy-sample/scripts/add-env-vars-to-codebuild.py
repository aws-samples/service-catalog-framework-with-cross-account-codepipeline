import argparse
import json
from cfn_flip import flip, to_yaml, to_json
import yaml

def main():
    parser = argparse.ArgumentParser(description='Pass CloudFormation parameters to CodeBuild environment variables')
    parser.add_argument('--template-file', type=str,required=True, help='Path to the CloudFormation YAML template')
    args = parser.parse_args()

    # Load the existing CloudFormation template
    with open(args.template_file, 'r') as f:
        template = json.loads(flip(f.read()))
    
    # Extract all the parameters from the CloudFormation template
    parameters = template.get('Parameters', {})
    
    # Iterate over each resource and add the parameters as environment variables
    for resource_name, resource in template.get('Resources', {}).items():
        if resource.get('Type') == 'AWS::CodeBuild::Project':
            environment_variables = resource.get('Properties', {}).get('Environment', {}).get('EnvironmentVariables', [])
            for parameter_name, parameter in parameters.items():
                # Check if an environment variable with the same name already exists
                if not any(env_var['Name'] == parameter_name for env_var in environment_variables):
                    environment_variables.append({
                        'Name': parameter_name,
                        'Type': "PLAINTEXT",
                        'Value': {"Ref": parameter_name}
                    })
            resource['Properties']['Environment']['EnvironmentVariables'] = environment_variables
    
    # Write the updated CloudFormation template back to the file
    print(yaml.dump(template))

if __name__ == '__main__':
    main()
