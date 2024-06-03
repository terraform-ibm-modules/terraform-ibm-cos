terraform {
  required_version = ">= 1.4.0, <1.7.0"

  # Use a flexible range in modules that future proofs the module's usage with upcoming minor and patch versions
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.66.0, < 2.0.0"
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
