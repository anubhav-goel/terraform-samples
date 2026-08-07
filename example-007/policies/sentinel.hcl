policy "s3-create" {
  source            = "./s3-create.sentinel"
  enforcement_level = "soft-mandatory"
}

policy "s3-update" {
  source            = "./s3-update.sentinel"
  enforcement_level = "soft-mandatory"
}