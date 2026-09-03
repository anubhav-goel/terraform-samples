# OPA enforcement levels: "advisory" (non-blocking) and "mandatory" (blocking, overridable).
# OPA has no "soft-mandatory" label — "mandatory" is used here; it stops the run and shows
# an Override and Continue button to users with Manage Policy Overrides permission.

policy "policy-soft-mandatory-fails" {
  query             = "data.terraform.soft_mandatory_fails.deny"
  enforcement_level = "mandatory"
}
