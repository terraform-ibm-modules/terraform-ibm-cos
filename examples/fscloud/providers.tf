provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
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
  servicekey = module.observability_instances.log_analysis_resource_key != null ? module.observability_instances.log_analysis_resource_key : ""
  url        = local.at_endpoint
}
