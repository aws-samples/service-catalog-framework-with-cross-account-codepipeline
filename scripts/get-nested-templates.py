import argparse
import cfn_flip
import json
import os


def print_nested_template_paths(template, template_path, resource_names=None, print_full_paths=False):
    for k, v in template.items():
        if isinstance(v, dict):
            if v.get('Type') == 'AWS::CloudFormation::Stack':
                nested_template_path = v.get('Properties', {}).get('TemplateURL')
                if nested_template_path:
                    resource_name = k
                    if resource_names is None or resource_name in resource_names:
                        nested_template_full_path = os.path.join(os.path.dirname(template_path), nested_template_path)
                        if print_full_paths:
                            print(os.path.abspath(nested_template_full_path))
                        else:
                            print(nested_template_path)
            else:
                print_nested_template_paths(v, template_path, resource_names, print_full_paths)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--template-file',required=True, help='Name of the CloudFormation template file')
    parser.add_argument('-r', '--resource', required=False, action='append', help='Name of an AWS::CloudFormation::Stack resource to filter')
    parser.add_argument('--print-full-paths', required=False, action='store_true', help='Print absolute file paths to nested templates')
    args = parser.parse_args()

    with open(args.template_file, 'r') as f:
        template = json.loads(cfn_flip.to_json(f.read()))

    print_nested_template_paths(template, args.template_file, args.resource, args.print_full_paths)
