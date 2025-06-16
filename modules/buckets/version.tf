terraform {
  required_version = ">= 1.9.0"

  # Use a flexible range in modules that future proofs the module's usage with upcoming minor and patch versions
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.79.1, < 2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
  }
}
