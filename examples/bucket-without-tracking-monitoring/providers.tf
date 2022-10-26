# ibmcloud_api_key is only required for tests, due to need to create resource group
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}
