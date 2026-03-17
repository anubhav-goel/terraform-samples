variable "bucket_name" {
  description = "The globally unique name for the S3 bucket"
  type        = string
}

variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
