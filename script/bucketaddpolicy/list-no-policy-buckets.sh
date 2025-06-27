#!/bin/bash
OUTPUT_FILE="s3_no_policy_buckets_$(date +%Y%m%d_%H%M%S).txt"

echo "S3 Buckets without bucket policies:" | tee -a "$OUTPUT_FILE"
echo "---------------------------------" | tee -a "$OUTPUT_FILE"

for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
  if ! aws s3api get-bucket-policy --bucket "$bucket" > /dev/null 2>&1; then
    echo "$bucket" | tee -a "$OUTPUT_FILE"
  fi
done

echo -e "\nResults saved to: $OUTPUT_FILE"