package terraform.syntax_err_policy

# Always passes: deny is an incremental rule whose body is always false.
# Uses old-style deny[msg] syntax — compatible with all OPA versions (no imports needed).
deny[msg] {
  false
  msg := "unreachable"
