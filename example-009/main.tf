terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "random" {}

resource "random_string" "label" {
  length  = 16
  special = false
  upper   = false
}

output "generated_label" {
  value = random_string.label.result
}
