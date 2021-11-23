####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

locals {
  bucket_name_prefix = var.bucket_name_prefix == "" ? "" : join("-", [var.bucket_name_prefix, lower(var.location), ""])
  site_location      = length(var.location) > 4 && length(regexall("-", var.location)) == 0 ? var.location : null
  reg_location       = length(regexall("-", var.location)) > 0 ? var.location : null
  cross_reg_location = length(var.location) == 2 ? var.location : null

}

resource "ibm_cos_bucket" "bucket" {

  bucket_name           = "${local.bucket_name_prefix}${var.bucket_name}"
  resource_instance_id  = var.cos_instance_id
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
    for_each = var.archive_rule == null ? [] : list(var.archive_rule)

    content {
      rule_id = lookup(archive_rule.value, "rule_id", null)
      enable  = lookup(archive_rule.value, "enable", true)
      days    = lookup(archive_rule.value, "days", 0)
      type    = lookup(archive_rule.value, "type", "Glacier")
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
