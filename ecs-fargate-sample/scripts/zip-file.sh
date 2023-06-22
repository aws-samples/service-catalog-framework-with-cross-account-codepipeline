#!/bin/bash

# Check if the correct number of parameters are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <zip_file_path> <directory_path>"
    exit 1
fi

zip_file_path="$1"
directory_path="$2"

# Change to the directory above the second argument
cd $directory_path
pwd
echo "$1"


# Zip the file to the path of the first argument
zip -r "$zip_file_path" .
