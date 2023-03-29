##############################################################################
# Terraform Version
##############################################################################
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.51.0"
    }
  }
}
