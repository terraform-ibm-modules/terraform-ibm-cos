##############################################################################
# Terraform Version
##############################################################################
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.66.0, <2.0.0"
    }
  }
}
