terraform {
  required_version = ">= 1.9.0"

  # Use a flexible range in modules that future proofs the module's usage with upcoming minor and patch versions
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.80.0, < 2.0.0"
    }
  }
}
