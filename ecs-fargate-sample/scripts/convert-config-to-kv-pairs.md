# convert-config-to-kv-pairs

This script extracts key-value pairs from a JSON file.


## Usage

python key_value_extractor.py --json-file <path_to_json_file> --key-value-type <parameters|tags>

The --json-file argument specifies the path to the JSON file to extract the key-value pairs from. The --key-value-type argument specifies the type of key-value pairs to extract, which can be either "parameters" or "tags".

If the CreateParameter or CreateTag field in the JSON object is set to False, then that key-value pair will be skipped.

## Output

The script will output a space-separated list of key=value pairs that can be used as the value for ```--parameters``` command line argument.

Example:

Suppose the following JSON file example.json:


```json
{
    "Configuration": [
        {
            "Key": "Environment",
            "Value": "Production",
            "CreateParameter": true
        },
        {
            "Key": "Application",
            "Value": "MyApp",
            "CreateParameter": true
        },
        {
            "Key": "Owner",
            "Value": "John Doe",
            "CreateTag": true
        },
        {
            "Key": "Environment",
            "Value": "Development",
            "CreateParameter": false
        },
        {
            "Key": "Application",
            "Value": "",
            "CreateParameter": true
        },
        {
            "Key": "Owner",
            "Value": "",
            "CreateTag": false
        }
    ]
}
````

Running the script with the following command:

```python convert-config-to-kv-pairs.py --json-file example.json --key-value-type parameters```

will output:

```Environment="Production" Application="MyApp"```

and used in ```sam deploy``` to populate the parameters in the template.

```bash
export Parameters=$(python3 $FrameworkScriptsDir/convert-config-to-kv-pairs.py --json-file replaced-vars.tmp --key-value-type parameters)


sam deploy  --template-file  .aws-sam/build/template.yaml  --stack-name  my-stack \
--capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
--resolve-s3 \
--no-fail-on-empty-changeset \
--parameter-overrides "$Parameters"
```