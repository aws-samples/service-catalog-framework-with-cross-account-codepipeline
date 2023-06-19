# JSON Configuration File Specification

This document outlines the structure and properties of the JSON configuration file used in this program. The configuration file contains parameters that are used to create and associate tag options with an AWS CloudFormation product.

## File Structure

The JSON configuration file should contain a single JSON object with the following structure:

```json
{
  "Configuration": [
    {
      "Key": "string",
      "Value": "string",
      "Default": "string",
      "CreateTag": true,
      "AllowedValues": ["string1", "string2", ...]
    },
    ...
  ]
}
```

### Property Descriptions

| Property Name | Description |
| --- | --- |
| Key | The unique identifier for the tag option. This value must be between 1 and 127 characters long and can only contain alphanumeric characters and hyphens (-). |
| Value | The value of the tag option. If this property is not specified, the value of the Default property will be used instead. |
| Default | The default value of the tag option. If the Value property is not specified, this value will be used instead. |
| CreateTag | A boolean value that indicates whether or not to create a tag option for this configuration parameter. |
| AllowedValues | An optional array of allowed values for the tag option. If this property is specified, a tag option section will be created for the key and each value in the array, instead of using the Default or Value property. |

Note that if the AllowedValues property is specified, the Value and Default properties will be ignored.

Additionally, when creating a tag option section, the tag option name will be in the format `TagOption<Key><Value>` and must be unique and no more than 64 characters long.
