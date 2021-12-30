#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

locals {
  bucket_name_prefix = var.bucket_name_prefix == "" ? "" : join("-", [var.bucket_name_prefix, lower(var.location), ""])
  site_location      = length(var.location) > 4 && length(regexall("-", var.location)) == 0 ? var.location : null
  reg_location       = length(regexall("-", var.location)) > 0 ? var.location : null
  cross_reg_location = length(var.location) == 2 ? var.location : null

}

data "ibm_resource_instance" "data_cos_instance" {
  count = var.is_new_cos_instance ? 0 : 1

  name              = var.cos_instance_name
  location          = var.region
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
}

resource "ibm_resource_instance" "cos_instance" {
  count             = (var.is_new_cos_instance ? 1 : 0)
  name              = var.cos_instance_name
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
  plan              = var.plan
  location          = var.region
  tags              = (var.tags != null ? var.tags : null)
  parameters        = (var.parameters != null ? var.parameters : null)
  service_endpoints = (var.service_endpoints != null ? var.service_endpoints : null)

  timeouts {
    create = (var.create_timeout != null ? var.create_timeout : null)
    update = (var.update_timeout != null ? var.update_timeout : null)
    delete = (var.delete_timeout != null ? var.delete_timeout : null)
  }
}


resource "ibm_resource_key" "key" {
  count                = var.is_bind_resource_key ? 1 : 0
  name                 = var.resource_key_name
  role                 = var.role
  parameters           = { "HMAC" = var.hmac_credential }
  resource_instance_id = (var.is_new_cos_instance ? ibm_resource_instance.cos_instance[0].id : data.ibm_resource_instance.data_cos_instance[0].id)
  tags                 = (var.key_tags != null ? var.key_tags : null)

  timeouts {
    create = (var.create_timeout != null ? var.create_timeout : null)
    delete = (var.delete_timeout != null ? var.delete_timeout : null)
  }
}

resource "ibm_cos_bucket" "bucket" {
  count                 = length(var.bucket_names)
  bucket_name           = "${local.bucket_name_prefix}${var.bucket_names[count.index]}"
  resource_instance_id  = var.is_new_cos_instance ? ibm_resource_instance.cos_instance[0].id : data.ibm_resource_instance.data_cos_instance[0].id
  single_site_location  = local.site_location
  region_location       = local.reg_location
  cross_region_location = local.cross_reg_location
  storage_class         = var.storage_class
  force_delete          = (var.force_delete != null ? var.force_delete : true)
  endpoint_type         = (var.endpoint_type != null ? var.endpoint_type : "public")
  allowed_ip            = (var.allowed_ip != null ? var.allowed_ip : null)
  key_protect           = (var.kms_key_crn != null ? var.kms_key_crn : null)

  dynamic "activity_tracking" {
    for_each = var.activity_tracker_crn == "" ? [] : [1]
    content {
      read_data_events     = (var.read_data_events != null ? var.read_data_events : false)
      write_data_events    = (var.write_data_events != null ? var.write_data_events : false)
      activity_tracker_crn = var.activity_tracker_crn
    }
  }
  dynamic "metrics_monitoring" {
    for_each = var.metrics_monitoring_crn == "" ? [] : [1]
    content {
      usage_metrics_enabled  = (var.usage_metrics_enabled != null ? var.usage_metrics_enabled : false)
      metrics_monitoring_crn = var.metrics_monitoring_crn
    }
  }

  dynamic "archive_rule" {

    for_each = [for rule in var.archive_rules : {
      archive_rule_id     = lookup(rule, "rule_id", null)
      archive_rule_enable = lookup(rule, "enable", true)
      archive_rule_days   = lookup(rule, "days", 0)
      archive_rule_type   = lookup(rule, "type", "Glacier")
    }]

    content {
      rule_id = archive_rule.value.archive_rule_id
      enable  = archive_rule.value.archive_rule_enable
      days    = archive_rule.value.archive_rule_days
      type    = archive_rule.value.archive_rule_type

    }
  }

  dynamic "expire_rule" {
    for_each = [for rule in var.expire_rules : {
      expire_rule_id     = rule.rule_id
      expire_rule_enable = lookup(rule, "enable", true)
      expire_rule_days   = lookup(rule, "days", 365)
      expire_rule_prefix = lookup(rule, "prefix", "logs/")
    }]

    content {
      rule_id = expire_rule.value.expire_rule_id
      enable  = expire_rule.value.expire_rule_enable
      days    = expire_rule.value.expire_rule_days
      prefix  = expire_rule.value.expire_rule_prefix

    }
  }
}
