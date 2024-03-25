provider "ibm" {
  alias            = "cos"
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "ibm" {
  alias            = "kms"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.kms_region
}
