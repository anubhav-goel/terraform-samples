# PLAN ONLY - never apply (S3 bucket quota, globally unique names, cost).
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

resource "aws_s3_bucket" "perf" {
  count  = 10000
  bucket = "sentinel-perf-10000-${count.index}"
}
