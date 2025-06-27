#!/bin/bash

# Create timestamp for output file
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="s3_no_policy_buckets_${TIMESTAMP}.txt"
POLICY_FILE="ssl_only_policy.json"

# Policy JSON file - more reliable than storing in variable
cat > "$POLICY_FILE" << 'EOL'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::BUCKET_NAME",
                "arn:aws:s3:::BUCKET_NAME/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOL

# Step 1: Find all buckets without policies
echo "1. Scanning for S3 buckets without policies..."
echo "S3 Buckets without bucket policies:" | tee "$REPORT_FILE"
echo "---------------------------------" | tee -a "$REPORT_FILE"

for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
    if ! aws s3api get-bucket-policy --bucket "$bucket" >/dev/null 2>&1; then
        echo "$bucket" | tee -a "$REPORT_FILE"
    fi
done

echo -e "\nResults saved to: $REPORT_FILE"

# Step 2: Apply SSL-only policy to found buckets
echo -e "\n2. Applying SSL-only policy to buckets without policies..."
COUNT=0
TOTAL=$(wc -l < "$REPORT_FILE" | tr -d ' ')
[ "$TOTAL" -lt 2 ] && TOTAL=0 # Account for header lines

while IFS= read -r bucket; do
    # Skip header lines and empty lines
    [[ "$bucket" =~ ^S3|^-|^$ ]] && continue
    
    echo "Processing bucket: $bucket"
    # Create temp policy file with current bucket name
    sed "s/BUCKET_NAME/$bucket/g" "$POLICY_FILE" > "temp_policy.json"
    
    if aws s3api put-bucket-policy --bucket "$bucket" --policy "file://temp_policy.json"; then
        echo "Successfully applied policy to $bucket"
        ((COUNT++))
    else
        echo "ERROR: Failed to apply policy to $bucket"
    fi
    
    rm -f "temp_policy.json"
done < "$REPORT_FILE"

echo -e "\nOperation complete!"
echo "Buckets processed: $COUNT/$TOTAL"
echo "Policy template: $POLICY_FILE"
echo "Bucket list: $REPORT_FILE"

# Cleanup
rm -f "$POLICY_FILE"