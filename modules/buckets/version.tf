terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.56.1, < 2.0.0"
    }
  }
}
