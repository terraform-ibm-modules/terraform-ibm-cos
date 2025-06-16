##############################################################################
# Terraform Version
##############################################################################
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.79.2, < 2.0.0"
    }
  }
}
