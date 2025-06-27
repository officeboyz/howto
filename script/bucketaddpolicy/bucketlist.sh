#!/bin/bash

# Get the list of all S3 buckets
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

# Initialize an empty array to hold buckets without policies
buckets_without_policy=()

# Loop through each bucket and check for a bucket policy
for bucket in $buckets; do
    # Try to get the bucket policy
    policy=$(aws s3api get-bucket-policy --bucket "$bucket" 2>/dev/null)

    # Check if the policy is empty (i.e., no policy exists)
    if [ -z "$policy" ]; then
        buckets_without_policy+=("$bucket")
    fi
done

# Print the buckets without policies
echo "Buckets without policies:"
for bucket in "${buckets_without_policy[@]}"; do
    echo "$bucket"
done