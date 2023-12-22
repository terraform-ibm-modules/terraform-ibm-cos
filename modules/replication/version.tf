terraform {
  required_version = ">= 1.0.0, <1.6.0"

  # Ensure that there is always 1 example locked into the lowest provider version of the range defined in the main
  # module's version.tf (this example), and 1 example that will always use the latest provider version (advanced and fscloud examples).
  #required_providers {
  #  ibm = {
  #    source  = "ibm-cloud/ibm"
  #    version = "1.56.1"
  #  }
  #}
}
