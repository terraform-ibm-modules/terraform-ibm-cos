#####################################################
# activity tracker as a service
# Copyright 2020 IBM
#####################################################

/***************************************************

terraform {
  required_version = ">=0.13"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.20.0"
    }
  }
}
If we dont configure the version parameter,
it fetches latest provider version.
****************************************************/

terraform {
  required_version = ">=0.13"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}
