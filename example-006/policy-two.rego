package terraform.policy_two

# Always passes: deny is a partial rule that never fires (empty set of violations).
# Do NOT add deny := set() (complete rule) — it would shadow partial deny rules.
deny contains msg if {
  false
  msg := "unreachable"
}
