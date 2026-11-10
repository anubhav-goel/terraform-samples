#!/usr/bin/env bash
# Generates the Sentinel performance matrix for example-010.
#
#   policy-sets/policies-<P>/  P Sentinel policies, each iterating every
#                              null/random/time resource in tfplan/v2 (cost scales with resources)
#   workspaces/resources-<L>/  Terraform config creating N dummy resources via count
#                              (50% null_resource, 30% random_pet, 20% time_static)
#
# Idempotent: policy-sets/ and workspaces/ are deleted and recreated on every run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

POLICY_COUNTS=(100 200 300 400 500 1100 1500)

# "<label> <resource count>" - label names the folder only; resource names use the numeric count.
WORKSPACES=(
  "1k 1000"
  "2.5k 2500"
  "3.75k 3750"
  "5k 5000"
  "7.5k 7500"
  "10k 10000"
)

policy_body() {
  cat <<'POLICY_BODY'
import "tfplan/v2" as tfplan

name_of = func(rc) {
	case rc.type {
		when "null_resource", "time_static":
			return rc.change.after.triggers.name
		when "random_pet":
			return rc.change.after.prefix
		else:
			return ""
	}
}

resources = filter tfplan.resource_changes as _, rc {
	rc.mode is "managed" and
	rc.type in ["null_resource", "random_pet", "time_static"] and
	(rc.change.actions contains "create" or rc.change.actions contains "update")
}

main = rule {
	all resources as _, rc {
		name_of(rc) matches "^sentinel-perf-"
	}
}
POLICY_BODY
}

rm -rf policy-sets workspaces
mkdir -p policy-sets workspaces

for p in "${POLICY_COUNTS[@]}"; do
  set_dir="policy-sets/policies-${p}"
  mkdir -p "$set_dir"
  : > "$set_dir/sentinel.hcl"

  for ((i = 1; i <= p; i++)); do
    printf -v name 'policy-%03d' "$i"

    {
      printf '# %s\n' "$name"
      policy_body
    } > "$set_dir/${name}.sentinel"

    if ((i > 1)); then
      printf '\n' >> "$set_dir/sentinel.hcl"
    fi
    cat >> "$set_dir/sentinel.hcl" <<HCL
policy "${name}" {
  source            = "./${name}.sentinel"
  enforcement_level = "hard-mandatory"
}
HCL
  done
done

for entry in "${WORKSPACES[@]}"; do
  read -r label resource_count <<<"$entry"
  dir="workspaces/resources-${label}"
  mkdir -p "$dir"
  cat > "$dir/main.tf" <<TF
# Dummy resources only - safe to plan and apply (no cloud API calls).
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

variable "prefix" {
  description = "Unique per workspace, e.g. ws-a. Lowercase letters, digits, hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,19}$", var.prefix))
    error_message = "prefix must be 1-20 chars of lowercase letters, digits or hyphens, starting with a letter or digit."
  }
}

locals {
  n    = ${resource_count}
  base = "sentinel-perf-\${var.prefix}-${resource_count}"
}

# 50%
resource "null_resource" "job" {
  count = floor(local.n * 0.5)
  triggers = {
    name  = "\${local.base}-job-\${count.index}"
    env   = "perf"
    owner = "sentinel-perf"
  }
}

# 30%
resource "random_pet" "pet" {
  count  = floor(local.n * 0.3)
  prefix = "\${local.base}-pet-\${count.index}"
}

# remainder (~20%)
resource "time_static" "stamp" {
  count = local.n - floor(local.n * 0.5) - floor(local.n * 0.3)
  triggers = {
    name = "\${local.base}-time-\${count.index}"
  }
}
TF
done

printf 'Generated policy sets in %s/policy-sets and workspaces in %s/workspaces\n' "$SCRIPT_DIR" "$SCRIPT_DIR"
