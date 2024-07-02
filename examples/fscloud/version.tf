terraform {
  required_version = ">= 1.4.0"

  # Ensure that there is always 1 example locked into the lowest provider version of the range defined in the main
  # module's version.tf (basic example), and 1 example that will always use the latest provider version (this example).
  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
      # version = ">= 1.67.0-beta1, < 2.0.0"
      version = "1.67.0-beta1"
    }
    logdna = {
      source  = "logdna/logdna"
      version = ">= 1.14.2, < 2.0.0"
    }
  }
}
