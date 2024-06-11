provider "ibm" {
  alias            = "cos"
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "ibm" {
  alias            = "kms"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.existing_kms_instance_region
}
