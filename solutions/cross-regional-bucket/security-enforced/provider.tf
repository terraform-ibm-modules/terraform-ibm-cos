provider "ibm" {
  alias            = "cos"
  ibmcloud_api_key = var.ibmcloud_api_key
  visibility       = "private"
}

provider "ibm" {
  alias            = "kms"
  ibmcloud_api_key = var.ibmcloud_kms_api_key != null ? var.ibmcloud_kms_api_key : var.ibmcloud_api_key
  region           = local.kms_region
  visibility       = "private"
}
