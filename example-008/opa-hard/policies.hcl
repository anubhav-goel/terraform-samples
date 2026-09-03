# OPA enforcement levels: "advisory" (non-blocking) and "mandatory" (blocking, overridable).
# OPA has no "hard-mandatory" level. "mandatory" is the only blocking level in OPA and is
# always overridable by users with Manage Policy Overrides permission — unlike Sentinel hard-mandatory.

policy "policy-hard-mandatory-fails" {
  query             = "data.terraform.hard_mandatory_fails.deny"
  enforcement_level = "mandatory"
}
