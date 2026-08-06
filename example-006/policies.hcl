policy "policy-one" {
  query             = "data.terraform.policy_one.deny"
  enforcement_level = "advisory"
}

policy "policy-two" {
  query             = "data.terraform.policy_two.deny"
  enforcement_level = "advisory"
}
