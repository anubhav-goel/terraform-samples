policy {
}

resource_policy "aws_s3_bucket" "always_pass" {
  enforce {
    condition = true
    error_message = "This will never fail."
  }
}