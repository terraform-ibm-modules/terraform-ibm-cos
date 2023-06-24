terraform {
  required_version = ">= 1.0.0"
  required_providers {
    # Use latest version of provider in non-basic examples to verify latest version works with module
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.54.0"
    }
    # The restapi provider is not actually required by the module itself, just this example, so OK to use ">=" here instead of locking into a version
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 1.18.0"
    }
    # The logdna provider is not actually required by the module itself, just this example, so OK to use ">=" here instead of locking into a version
    logdna = {
      source  = "logdna/logdna"
      version = ">= 1.14.2"
    }
  }
}
