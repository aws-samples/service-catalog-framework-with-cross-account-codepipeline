import argparse
import yaml
import json
import re
from cfn_flip import flip, to_yaml, to_json


parser = argparse.ArgumentParser()
parser.add_argument("--config-file", help="Path to the JSON config file", required=True)
parser.add_argument("--template-file", help="Path to the YAML CloudFormation template file", required=True)

args = parser.parse_args()

with open(args.config_file, "r") as f:
    config = json.load(f)


with open(args.template_file, 'r') as f:
    template = json.loads(to_json(f.read()))

resources = template.setdefault("Resources", {})

product_resource = None
for resource_name, resource in resources.items():
    if resource.get("Type") == "AWS::ServiceCatalog::Portfolio":
        portfolio_resource = resource_name
        break

if not portfolio_resource:
    raise Exception("No AWS::ServiceCatalog::Portfolio resource found in the template")

for param in config["Configuration"]:
    if "CreateTagOption" in param and not param["CreateTagOption"]:
        continue
    if "AllowedValues" in param:
        for value in param["AllowedValues"]:
            tag_option_name = f"TagOption{param['Key']}{value}"
            if len(tag_option_name) > 64:
                tag_option_name = tag_option_name[:60] + "_" + str(hash(tag_option_name))[1:9]
            tag_option_resource = {
                "Type": "AWS::ServiceCatalog::TagOption",
                "Properties": {
                    "Key": f"{param['Key']}",
                    "Value": value,
                    "Active": True
                }
            }

            resources[tag_option_name] = tag_option_resource
            tag_option_association_name = f"TagOptionAssociation{param['Key']}{value}"
            tag_option_association_resource = {
                "Type": "AWS::ServiceCatalog::TagOptionAssociation",
                "Properties": {
                    "TagOptionId": {"Ref": tag_option_name},
                    "ResourceId": {"Ref": portfolio_resource},
                }
            }
            resources[tag_option_association_name] = tag_option_association_resource
    else:
        value = param["Value"] if param["Value"] else param["Default"]
        tag_option_name = f"TagOption{param['Key']}"
        if len(tag_option_name) > 64:
            tag_option_name = tag_option_name[:60] + "_" + str(hash(tag_option_name))[1:9]
            tag_option_name = re.sub(r'[\W_]+', '', tag_option_name)
        tag_option_resource = {
            "Type": "AWS::ServiceCatalog::TagOption",
            "Properties": {
                "Key": f"{param['Key']}",
                "Value": value,
                "Active": True
            }
        }
        resources[tag_option_name] = tag_option_resource
        tag_option_association_resource = {
            "Type": "AWS::ServiceCatalog::TagOptionAssociation",
            "Properties": {
                "TagOptionId": {"Ref": tag_option_name},
                "ResourceId": {"Ref": portfolio_resource},
            }
        }
        tag_option_association_name = f"TagOptionAssociation{param['Key']}{value}"
        tag_option_association_name = re.sub(r'[\W_]+', '', tag_option_association_name)
        resources[tag_option_association_name] = tag_option_association_resource



print(yaml.dump(template))