terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. The S3 Bucket Resource
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = var.env
  }
}

# 2. Ownership Controls (Prevents ACL issues)
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 3. Public Access Block (Security First)
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
