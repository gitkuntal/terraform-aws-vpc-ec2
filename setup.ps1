# 1. Define Variables
$BUCKET = "terraform-aws-vpc-ec2-bucket"
$REGION = "us-east-1"
$DDB_TABLE = "tf-state-locks"

# 2. Create S3 Bucket
Write-Host "Creating Bucket: $BUCKET in $REGION..."

# Logic to handle us-east-1 constraint
if ($REGION -eq "us-east-1") {
    aws s3api create-bucket `
      --bucket "$BUCKET" `
      --region "$REGION"
} else {
    aws s3api create-bucket `
      --bucket "$BUCKET" `
      --region "$REGION" `
      --create-bucket-configuration LocationConstraint=$REGION
}

# 3. Enable Versioning
Write-Host "Enabling Versioning..."
aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled

# 4. Enable Server-Side Encryption
Write-Host "Enabling Encryption..."
aws s3api put-bucket-encryption `
  --bucket "$BUCKET" `
  --server-side-encryption-configuration '{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}'

# 5. Create DynamoDB Table
Write-Host "Creating DynamoDB Table..."
aws dynamodb create-table `
  --table-name "$DDB_TABLE" `
  --attribute-definitions AttributeName=LockID,AttributeType=S `
  --key-schema AttributeName=LockID,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --region "$REGION"

# --- VERIFICATION STEPS ---

Write-Host "`n--- VERIFICATION ---"

# 6. Verify S3 Bucket
# Note: If this command runs successfully, it returns NOTHING (no output means success).
# If the bucket does not exist, it will throw a 404 error in red text.
Write-Host "Verifying S3 Bucket existence..."
aws s3api head-bucket --bucket "$BUCKET"

# 7. Verify DynamoDB Table
# This will output the table details in JSON format.
Write-Host "Verifying DynamoDB Table details..."
aws dynamodb describe-table --table-name "$DDB_TABLE" --region "$REGION"

Write-Host "Done!"