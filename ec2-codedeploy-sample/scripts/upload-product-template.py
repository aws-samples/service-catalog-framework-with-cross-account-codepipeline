# pylint: disable=C0114 #Disables missing docstring warning
# pylint: disable=C0116 #Disables missing function docstring warning
# pyline: disable=C0301 #Disable line too long
# pylint: disable=C0103 #Disables python script name does conform to snake_case, staying consistent with aws cli

import argparse
import hashlib
import boto3
import botocore

def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def local_md5Sum(file_name):
    with open(file_name, 'rb') as file_to_check:
        data = file_to_check.read()
    # needed for comparison with the S3 checksum. Suppressing bandit warning
    return hashlib.md5(data).hexdigest() #nosec B324

def s3_md5sum(bucket_name, key):
    try:
        md5sum = boto3.client('s3').head_object(
            Bucket=bucket_name,
            Key=key
        )['ETag'][1:-1]
    except botocore.exceptions.ClientError:  # type: ignore
        md5sum = None
    return md5sum

try:

    parser = argparse.ArgumentParser(description='Copies a file to S3 and optionally'+
        'creates a new version if the file has changed.')
    parser.add_argument('--file-name',required=True)
    parser.add_argument('--bucket-name',required=True)
    parser.add_argument('--should-version',required=True)


    args = parser.parse_args()

    s3_client = boto3.client("s3")
    should_version=str2bool(args.should_version)
    local_md5 = local_md5Sum(args.file_name)

    if should_version:
        s3_key = args.file_name.split("/")[-1]+"-"+local_md5
    else:
        s3_key = args.file_name.split("/")[-1]
    s3_md5=s3_md5sum(args.bucket_name,args.file_name)


    if(s3_md5 is None or (local_md5 != s3_md5)):
        s3_client.upload_file(args.file_name, args.bucket_name, s3_key)

    print(f"https://{args.bucket_name}.s3.amazonaws.com/{s3_key}")
except Exception as e:
    print(e)
    exit(-1)
