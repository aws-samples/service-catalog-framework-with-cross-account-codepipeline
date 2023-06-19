import argparse
import json

# Set up the command line argument parser
parser = argparse.ArgumentParser()
parser.add_argument("--json-file", dest="input_file", required=True, help="the input JSON file")
parser.add_argument("--key-value-type", dest="key_value_type", choices=["parameters", "tags"], required=True, help="the type of key-value pairs to extract")
args = parser.parse_args()

# Open the input file and parse the JSON
with open(args.input_file) as f:
    data = json.load(f)

# Initialize an empty set to store the keys
keys = set()

# Initialize an empty list to store the key=value pairs
pairs = []

# Iterate over the objects in the array
for obj in data["Configuration"]:
    # Extract the keys and values from the object
    if args.key_value_type == "parameters":
        if "CreateParameter" in obj and obj["CreateParameter"] == False:
            continue
    elif args.key_value_type == "tags":
        if "CreateTag" in obj and obj["CreateTag"] == False:
            continue
    if obj["Value"] == "":
        print(f"No value specified for {obj['Key']} and Create{args.key_value_type.capitalize()} is not set to False")
        exit(-1)
    key = obj["Key"].lower() # perform case-insensitive comparison by converting to lowercase
    value = obj["Value"]
    # Skip if the key already exists in the keys set
    if key in keys:
        continue
    # Add the key to the set
    keys.add(key)
    # Add the key=value pair to the list
    pairs.append(f"{obj['Key']}=\"{value}\"")

# Join the key=value pairs with a space and print the result
print(" ".join(pairs))
