terraform {
  required_version = ">= 1.9.0"

  # Lock DA into an exact provider version - renovate automation will keep it updated
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.14.0"
    }
  }
}
