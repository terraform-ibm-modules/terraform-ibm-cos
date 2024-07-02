terraform {
  required_version = ">= 1.4.0"

  # Use a flexible range in modules that future proofs the module's usage with upcoming minor and patch versions
  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
      # version = ">= 1.67.0-beta1, < 2.0.0"
      version = ">= 1.67.0-beta1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1, < 4.0.0"
    }
  }
}
