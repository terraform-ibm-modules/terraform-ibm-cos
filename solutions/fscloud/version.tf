terraform {
  required_version = ">= 1.3.0, <1.6.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.62.0"
    }
  }
}
