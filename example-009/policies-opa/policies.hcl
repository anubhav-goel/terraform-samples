policy "policy-always-passes" {
  query             = "data.terraform.always_passes.deny"
  enforcement_level = "advisory"
}
