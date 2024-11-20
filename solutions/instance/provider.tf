provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  ibmcloud_timeout = 60
  visibility       = var.provider_visibility
}
