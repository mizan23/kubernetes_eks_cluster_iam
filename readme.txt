🚀 Step 1: Create S3 bucket via AWS CLI

Run this:

aws s3api create-bucket \
  --bucket mizan-eks-tfstate-bucket \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1 \
  --profile mizan-ostad
🔐 Step 2: Enable versioning (important)
aws s3api put-bucket-versioning \
  --bucket mizan-eks-tfstate-bucket \
  --versioning-configuration Status=Enabled \
  --profile mizan-ostad
🔒 Step 3: Enable encryption
aws s3api put-bucket-encryption \
  --bucket mizan-eks-tfstate-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }' \
  --profile mizan-ostad
🚫 Step 4: Block public access (best practice)
aws s3api put-public-access-block \
  --bucket mizan-eks-tfstate-bucket \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --profile mizan-ostad
🔁 Step 5: Now re-run Terraform

Now your backend actually exists, so:

terraform init -migrate-state

👉 When prompted:

Do you want to copy existing state to the new backend?

Type:

yes
✅ Step 6: Verify
aws s3 ls s3://mizan-eks-tfstate-bucket/eks/dev/ --profile mizan-ostad

You should see:

terraform.tfstate


aws eks update-kubeconfig --region us-east-1 --name dev-eks-cluster --profile mizan-ostad