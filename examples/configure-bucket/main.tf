provider "ibm" {
  region = var.location
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "ibm_resource_instance" "at_instance" {

  name              = var.activity_tracker_name
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.activity_tracker_region
  resource_group_id = data.ibm_resource_group.group.id
}

locals {
  archive_rule_id = var.archive_rule_enabled ? "bucket-archive-rule-${ibm_resource_instance.at_instance.name}" : null
  expire_rule_id  = "bucket-expire-rule-${ibm_resource_instance.at_instance.name}"
}

module "cos" {
  // Uncommnet the following line to point the source to registry level
  //source                 = "terraform-ibm-modules/cos/ibm//modules/instance"

  source                 = "../../modules/instance"
  provision_cos_instance = true
  service_name           = var.cos_instance_name
  resource_group_id      = data.ibm_resource_group.group.id
  plan                   = var.cos_plan
  region                 = var.cos_location
  bind_resource_key      = var.bind_resource_key
  resource_key_name      = var.resource_key_name
  role                   = var.role
}


module "cos_bucket" {

  // Uncommnet the following line to point the source to registry level
  //source               = "terraform-ibm-modules/cos/ibm//modules/bucket"

  source               = "../../modules/bucket"
  count                = length(var.bucket_names)
  bucket_name          = var.bucket_names[count.index]
  cos_instance_id      = module.cos.cos_instance_id
  location             = var.location
  storage_class        = var.storage_class
  force_delete         = var.force_delete
  endpoint_type        = var.endpoint_type
  activity_tracker_crn = ibm_resource_instance.at_instance.id
  archive_rule = {
    rule_id = local.archive_rule_id
    enable  = true
    days    = 0
    type    = "GLACIER"
  }
  expire_rules = [{
    rule_id = local.expire_rule_id
    enable  = true
    days    = 365
    prefix  = "logs/"
  }]
}
