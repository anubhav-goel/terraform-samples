policy "policy-one" {
  source            = "./policy-one.rego"
  enforcement_level = "hard-mandatory"
  query             = "data.policy_one.main"
}

policy "policy-two" {
  source            = "./policy-two.rego"
  enforcement_level = "advisory"
  query             = "data.policy_two.main"
}
