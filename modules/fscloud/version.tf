##############################################################################
# Terraform Version
##############################################################################
terraform {
  required_version = ">= 1.4.0, <1.6.0"
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.56.1, <2.0.0"
    }
  }
}
