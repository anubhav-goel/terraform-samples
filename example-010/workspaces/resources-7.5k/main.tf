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

variable "prefix" {
  description = "Unique per workspace, e.g. ws-a. Lowercase letters, digits, hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,19}$", var.prefix))
    error_message = "prefix must be 1-20 chars of lowercase letters, digits or hyphens, starting with a letter or digit."
  }
}

resource "aws_s3_bucket" "perf" {
  count  = 7500
  bucket = "sentinel-perf-${var.prefix}-7500-${count.index}"
}
