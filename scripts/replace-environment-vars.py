import argparse
import json
import os
import re

# Set up the command line argument parser
parser = argparse.ArgumentParser()
parser.add_argument("--json-file", dest="input_file", help="the input JSON file")
args = parser.parse_args()

# Open the input file and parse the JSON
with open(args.input_file) as f:
    data = json.load(f)

# Get the array of key/value objects from the Configuration key
obj_array = data["Configuration"]

# Define a regular expression to match environment variable replacements
env_var_regex = r"\${([^}]*)}"

# Iterate over the objects in the array and their indexes
for i, obj in enumerate(obj_array):
    # Create a new dictionary to store the updated object
    updated_obj = {}
    if "CreateParameter" in obj and not obj["CreateParameter"]:
        continue
    # Iterate over the keys and values in the object
    for key, value in obj.items():

        # Check if the value is a string
        if isinstance(value, str):
            # Find all environment variable replacements in the value
            matches = re.findall(env_var_regex, value)
            for match in matches:
                # Extract the environment variable name from the match
                env_var = match.strip()
                # Check if the environment variable is set
                if env_var in os.environ:
                    # Replace the match with the environment variable value
                    value = value.replace(f"${{{env_var}}}", os.environ[env_var])
                else:
                    # Check if the "Default" key is present in the object
                    if "Default" in obj:
                        # Replace the match with the Default value
                        value = value.replace(f"${{{env_var}}}", obj["Default"])
                    else:
                        raise Exception(f"${{{env_var}}} found in file but is not a defined environment variable")

            # Check if the value still contains an environment variable replacement
            if re.search(env_var_regex, value):
                raise Exception(f"Value {value} for key {key} contains an undefined environment variable")

        # Add the key and value to the updated object
        updated_obj[key] = value

    # Replace the original object in the array with the updated object
    obj_array[i] = updated_obj

# Print the updated data
print(json.dumps(data, indent=4))
