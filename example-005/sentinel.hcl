policy "policy-always-passes" {
  source            = "./policy-always-passes.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "policy-hard-mandatory-fails" {
  source            = "./policy-hard-mandatory-fails.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "policy-soft-mandatory-fails" {
  source            = "./policy-soft-mandatory-fails.sentinel"
  enforcement_level = "soft-mandatory"
}

policy "policy-advisory-fails" {
  source            = "./policy-advisory-fails.sentinel"
  enforcement_level = "advisory"
}

policy "policy-syntax-error" {
  source            = "./policy-syntax-error.sentinel"
  enforcement_level = "hard-mandatory"
}
