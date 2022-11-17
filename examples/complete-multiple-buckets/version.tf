terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # Pin to the lowest provider version of the range defined in the main module to ensure lowest version still works
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.45.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 1.17.0"
    }
  }
}
