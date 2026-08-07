policy "policy-always-passes" {
  query             = "data.terraform.always_passes.deny"
  enforcement_level = "advisory"
}

policy "policy-mandatory-fails" {
  query             = "data.terraform.mandatory_fails.deny"
  enforcement_level = "mandatory"
}

policy "policy-advisory-fails" {
  query             = "data.terraform.advisory_fails.deny"
  enforcement_level = "advisory"
}

# policy "policy-syntax-error" {
#   query             = "data.terraform.syntax_error.deny"
#   enforcement_level = "mandatory"
# }
