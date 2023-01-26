# used by the restapi provider to authenticate the API call based on API key
data "ibm_iam_auth_token" "token_data" {
}

provider "restapi" {
  uri                   = "https:"
  write_returns_object  = false
  create_returns_object = false
  debug                 = false # set to true to show detailed logs, but use carefully as it might print sensitive values.
  headers = {
    Authorization    = data.ibm_iam_auth_token.token_data.iam_access_token
    Bluemix-Instance = module.key_protect_all_inclusive.key_protect_guid
    Content-Type     = "application/vnd.ibm.kms.policy+json"
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

locals {
  at_endpoint = "https://api.${var.region}.logging.cloud.ibm.com"
}

provider "logdna" {
  alias      = "at"
  servicekey = module.observability_instances.activity_tracker_resource_key != null ? module.observability_instances.activity_tracker_resource_key : ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld"
  servicekey = module.observability_instances.logdna_resource_key != null ? module.observability_instances.logdna_resource_key : ""
  url        = local.at_endpoint
}
