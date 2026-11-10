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
  n    = 1000
  base = "sentinel-perf-${var.prefix}-1000"
}

# 50%
resource "null_resource" "job" {
  count = floor(local.n * 0.5)
  triggers = {
    name  = "${local.base}-job-${count.index}"
    env   = "perf"
    owner = "sentinel-perf"
  }
}

# 30%
resource "random_pet" "pet" {
  count  = floor(local.n * 0.3)
  prefix = "${local.base}-pet-${count.index}"
}

# remainder (~20%)
resource "time_static" "stamp" {
  count = local.n - floor(local.n * 0.5) - floor(local.n * 0.3)
  triggers = {
    name = "${local.base}-time-${count.index}"
  }
}
