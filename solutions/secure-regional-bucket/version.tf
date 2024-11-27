terraform {
  required_version = ">= 1.3.0"

  # Lock DA into an exact provider version - renovate automation will keep it updated
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.71.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}
