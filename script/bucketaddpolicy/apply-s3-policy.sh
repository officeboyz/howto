#!/bin/bash

# Load bucket names from the specified text file
buckets=()
while IFS= read -r line; do
    buckets+=("$line")
done  < "s3bucket.txt"
#done < "s3_no_policy_buckets_20250627_105128.txt"

# Policy JSON
policy='{
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::<Bucket_name>",
                "arn:aws:s3:::<Bucket_name>/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}'

# Loop through each bucket and apply the policy
for bucket in "${buckets[@]}"; do
    policy_for_bucket="${policy//<Bucket_name>/$bucket}"
    aws s3api put-bucket-policy --bucket "$bucket" --policy "$policy_for_bucket"
done