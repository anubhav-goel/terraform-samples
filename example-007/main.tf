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

resource "aws_s3_bucket" "my_bucket_1" {
  bucket = "my-simple-test-bucket-1786111606-1"
}

resource "aws_s3_bucket" "my_bucket_2" {
  bucket = "my-simple-test-bucket-1786111606-2"
}
