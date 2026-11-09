#!/usr/bin/env bash
# Generates the Sentinel performance matrix for example-010.
#
#   policy-sets/policies-<P>/  P Sentinel policies, each iterating every
#                              aws_s3_bucket in tfplan/v2 (cost scales with resources)
#   workspaces/resources-<L>/  Terraform config creating N aws_s3_bucket via count
#
# Idempotent: policy-sets/ and workspaces/ are deleted and recreated on every run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

POLICY_COUNTS=(100 200 300 400 500 1500)

# "<label> <bucket count>" - label names the folder only; bucket names use the numeric count.
WORKSPACES=(
  "1k 1000"
  "2.5k 2500"
  "5k 5000"
  "7.5k 7500"
  "10k 10000"
)

policy_body() {
  cat <<'POLICY_BODY'
import "tfplan/v2" as tfplan

buckets = filter tfplan.resource_changes as _, rc {
	rc.type is "aws_s3_bucket" and
	rc.mode is "managed" and
	(rc.change.actions contains "create" or rc.change.actions contains "update")
}

main = rule {
	all buckets as _, rc {
		rc.change.after.bucket matches "^sentinel-perf-"
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
  read -r label bucket_count <<<"$entry"
  dir="workspaces/resources-${label}"
  mkdir -p "$dir"
  cat > "$dir/main.tf" <<TF
# PLAN ONLY - never apply (S3 bucket quota, globally unique names, cost).
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "prefix" {
  description = "Unique per workspace, e.g. ws-a. Lowercase letters, digits, hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,19}$", var.prefix))
    error_message = "prefix must be 1-20 chars of lowercase letters, digits or hyphens, starting with a letter or digit."
  }
}

resource "aws_s3_bucket" "perf" {
  count  = ${bucket_count}
  bucket = "sentinel-perf-\${var.prefix}-${bucket_count}-\${count.index}"
}
TF
done

printf 'Generated policy sets in %s/policy-sets and workspaces in %s/workspaces\n' "$SCRIPT_DIR" "$SCRIPT_DIR"
