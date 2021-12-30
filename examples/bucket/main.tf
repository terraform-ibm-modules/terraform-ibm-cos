provider "ibm" {
  region = var.location
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}
data "ibm_resource_instance" "logdna_instance" {
  name              = var.logdna_instance_name
  location          = var.location
  resource_group_id = data.ibm_resource_group.group.id
  service           = "logdna"
}

data "ibm_resource_instance" "at_instance" {
  name              = var.at_instance_name
  location          = var.location
  resource_group_id = data.ibm_resource_group.group.id
  service           = "logdnaat"
}

locals {

  logdna-bucket   = "${data.ibm_resource_instance.logdna_instance.name}-cos-bucket"
  at-bucket       = "${data.ibm_resource_instance.at_instance.name}-cos-bucket"
  logdna_crn      = var.logdna_crn == "" ? data.ibm_resource_instance.logdna_instance.id : var.logdna_crn
  at_crn          = var.activity_tracker_crn == "" ? data.ibm_resource_instance.at_instance.id : var.activity_tracker_crn
  archive_rule_id = "bucket-archive-rule-${data.ibm_resource_instance.logdna_instance.name}"
  expire_rule_id  = "bucket-expire-rule-${data.ibm_resource_instance.at_instance.name}"
  bucket_list     = [local.logdna-bucket, local.at-bucket]
  crn_list        = [local.logdna_crn, local.at_crn]
}

module "cos" {
  // Uncommnet the following line to point the source to registry level
  //source               = "terraform-ibm-modules/cos/ibm//modules/instance"

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
  //source             = "terraform-ibm-modules/cos/ibm//modules/bucket"

  source               = "../../modules/bucket"
  count                = length(local.bucket_list)
  bucket_name          = local.bucket_list[count.index]
  cos_instance_id      = module.cos.cos_instance_id
  location             = var.location
  storage_class        = var.storage_class
  force_delete         = var.force_delete
  endpoint_type        = var.endpoint_type
  activity_tracker_crn = local.crn_list[count.index]
  allowed_ip           = var.allowed_ip
  kms_key_crn          = var.kms_key_crn

  archive_rules = [{
    rule_id = local.archive_rule_id
    enable  = true
    days    = 0
    type    = "GLACIER"
  }]

  expire_rules = [{
    rule_id = local.expire_rule_id
    enable  = true
    days    = 365
    prefix  = "logs/"
  }]
}
