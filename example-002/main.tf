terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "buckets" {
  count  = 1000
  bucket = "anubhav-goel-test-1778566461-${count.index + 1}"

  tags = {
    Name  = "anubhav-goel-test-1778566461-bucket-${count.index + 1}"
    Index = count.index + 1
  }
}
