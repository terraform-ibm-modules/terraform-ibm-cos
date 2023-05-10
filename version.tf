terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.51.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.1"
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}
