# replace-environment-vars

This is a Python script that reads a JSON file specified as a command line argument (`--json-file`) and replaces any environment variable references. The script expects a JSON file with an array of key-value objects, where each object represents a configuration.

## Usage

python environment_variable_replacer.py --json-file <path_to_json_file>

The `--json-file` argument specifies the path to the JSON file to extract the key-value pairs from.

## Input

The script reads the specified JSON file and extracts the array of key-value objects from the `Configuration` key.

If a value, is surrounded by ```${}```, it will be replaced by the corresponding environment variable.  If the environment variable is not found, then the ```Default``` value if specified will be used. If an environment variable is not found and a default variable is not specified, an error will be raised.

```json
{
    "Configuration": [
        {
            "Key": "Environment",
            "Value": "${Environment}",
            "Default":"Development",
        },
        {
            "Key": "Application",
            "Value": "${Application}",
        },
        {
            "Key": "Owner",
            "Value": "ACME International",
        },
        {
            "Key": "EC2Instance",
            "Value": "/acme/${Department}/${Environment}/ec2/instance/id",
            "Default":"/acme/anvil/dev/ec2/instance/id"
        }
    ]
}
````




