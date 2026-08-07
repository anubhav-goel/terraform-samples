policy "syntax-err-policy" {
  query             = "data.terraform.syntax_err_policy.deny"
  enforcement_level = "advisory"
}
