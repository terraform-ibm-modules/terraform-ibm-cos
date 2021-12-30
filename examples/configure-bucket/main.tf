provider "ibm" {
  region = var.location
}

locals {
  archive_rule_id = var.archive_rule_enabled && var.configure_activity_tracker ? (var.is_new_activity_tracker ? "bucket-archive-rule-${ibm_resource_instance.activity_tracker[0].name}" : "bucket-archive-rule-${data.ibm_resource_instance.data_activity_tracker[0].name}") : null
  expire_rule_id  = var.configure_activity_tracker ? (var.is_new_activity_tracker ? "bucket-expire-rule-${ibm_resource_instance.activity_tracker[0].name}" : "bucket-expire-rule-${data.ibm_resource_instance.data_activity_tracker[0].name}") : null
}

/***************************************************
Read resource group
***************************************************/
data "ibm_resource_group" "group" {
  name = var.resource_group
}

/*****************************************************
Read existing activity_tracker or create a new instance
*****************************************************/
data "ibm_resource_instance" "data_activity_tracker" {
  count = var.configure_activity_tracker && var.is_new_activity_tracker ? 0 : 1

  name              = var.activity_tracker_name
  location          = var.activity_tracker_region
  resource_group_id = data.ibm_resource_group.group.id
  service           = "logdnaat"
}

resource "ibm_resource_instance" "activity_tracker" {
  count             = var.configure_activity_tracker && var.is_new_activity_tracker ? 1 : 0
  name              = var.activity_tracker_name
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.activity_tracker_region
  resource_group_id = data.ibm_resource_group.group.id
}

/*****************************************************
Read existing sysdig monitoring or create a new instance
*****************************************************/
data "ibm_resource_instance" "data_sysdig_instance" {
  count = var.configure_sysdig_monitoring && var.is_new_sysdig_monitoring ? 0 : 1

  name              = var.sysdig_monitoring_name
  location          = var.sysdig_monitoring_region
  resource_group_id = data.ibm_resource_group.group.id
  service           = "sysdig-monitor"
}

resource "ibm_resource_instance" "sysdig_instance" {

  count = var.configure_sysdig_monitoring && var.is_new_sysdig_monitoring ? 1 : 0

  name              = var.sysdig_monitoring_name
  service           = "sysdig-monitor"
  plan              = var.sysdig_monitoring_plan
  location          = var.sysdig_monitoring_region
  resource_group_id = data.ibm_resource_group.group.id
}

module "cos" {

  source = "./../.."

  ##########################
  # COS Instance
  ##########################

  is_new_cos_instance = var.is_new_cos_instance
  cos_instance_name   = var.cos_instance_name
  resource_group_id   = data.ibm_resource_group.group.id
  plan                = var.plan
  region              = var.region
  tags                = var.tags
  service_endpoints   = var.service_endpoints

  ##########################
  # Service credentials
  ##########################

  is_bind_resource_key = var.is_bind_resource_key
  resource_key_name    = var.resource_key_name
  role                 = var.role
  hmac_credential      = var.hmac_credential
  key_tags             = var.key_tags

  ###########################
  # COS Bucket
  ###########################
  //count                  = length(var.bucket_names)
  bucket_names           = var.bucket_names
  bucket_name_prefix     = var.bucket_name_prefix
  location               = var.location
  storage_class          = var.storage_class
  force_delete           = var.force_delete
  endpoint_type          = var.endpoint_type
  activity_tracker_crn   = var.configure_activity_tracker ? (var.is_new_activity_tracker ? ibm_resource_instance.activity_tracker[0].id : data.ibm_resource_instance.data_activity_tracker[0].id) : null
  read_data_events       = var.configure_activity_tracker ? var.read_data_events : null
  write_data_events      = var.configure_activity_tracker ? var.write_data_events : null
  metrics_monitoring_crn = var.configure_sysdig_monitoring ? (var.is_new_sysdig_monitoring ? ibm_resource_instance.sysdig_instance[0].id : data.ibm_resource_instance.data_sysdig_instance[0].id) : null
  usage_metrics_enabled  = var.configure_sysdig_monitoring ? var.usage_metrics_enabled : null
  allowed_ip             = var.allowed_ip
  kms_key_crn            = var.kms_key_crn

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

  create_timeout = var.create_timeout
  update_timeout = var.update_timeout
  delete_timeout = var.delete_timeout
}
