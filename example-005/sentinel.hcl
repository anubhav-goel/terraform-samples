policy "policy-one" {
  source            = "./policy-one.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "policy-two" {
  source            = "./policy-two.sentinel"
  enforcement_level = "advisory"
}