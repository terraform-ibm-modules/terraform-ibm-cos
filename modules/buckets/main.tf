##############################################################################
# terraform-ibm-cos
#
# Create COS buckets
##############################################################################

locals {
  # input variable validation
  # tflint-ignore: terraform_unused_declarations
  # validate_key_inputs = var.create_cos_bucket && var.encryption_enabled && var.kms_key_crn == null ? tobool("A value must be passed for var.kms_key_crn when both var.create_cos_bucket and var.encryption_enabled are true") : true
}

# Create COS buckets from bucket_configs

module "buckets" {
  for_each = {
    for index, bucket in var.bucket_configs :
    bucket.bucket_name => bucket
  }
  source                   = "../../"
  bucket_name              = each.value.bucket_name
  create_cos_instance      = false
  existing_cos_instance_id = each.value.resource_instance_id
  resource_group_id        = var.resource_group_id
  region                   = each.value.region_location

  cross_region_location = each.value.cross_region_location
  bucket_storage_class  = each.value.storage_class
  kms_key_crn           = each.value.kms_key_crn
  encryption_enabled    = false

  activity_tracker_crn = can(each.value.activity_tracking.activity_tracker_crn) ? each.value.activity_tracking.activity_tracker_crn : null

  archive_days = can(each.value.archive_rule.days) ? (each.value.archive_rule.enable ? each.value.archive_rule.days : null) : null
  archive_type = can(each.value.archive_rule.type) ? (each.value.archive_rule.enable ? each.value.archive_rule.type : "Glacier") : "Glacier"

  expire_days = can(each.value.expire_rule.days) ? (each.value.expire_rule.enable ? each.value.expire_rule.days : null) : null

  sysdig_crn = can(each.value.metrics_monitoring.metrics_monitoring_crn) ? each.value.metrics_monitoring.metrics_monitoring_crn : null

  object_versioning_enabled = can(each.value.object_versioning.enable) ? each.value.object_versioning.enable : false

  retention_enabled   = can(each.value.retention_rule.default) || can(each.value.retention_rule.maximum) || can(each.value.retention_rule.minimum) || can(each.value.retention_rule.permanent) ? true : false
  retention_default   = can(each.value.retention_rule.default) ? each.value.retention_rule.default : 90
  retention_maximum   = can(each.value.retention_rule.maximum) ? each.value.retention_rule.maximum : 350
  retention_minimum   = can(each.value.retention_rule.minimum) ? each.value.retention_rule.minimum : 90
  retention_permanent = can(each.value.retention_rule.permanent) ? each.value.retention_rule.permanent : false
}

locals {
  cos_instance_guid = element(split(":", var.bucket_configs[0].resource_instance_id), length(split(":", var.bucket_configs[0].resource_instance_id)) - 3)
  bucket_name       = var.bucket_configs[0].bucket_name
  cbr_rules = (length(var.bucket_configs[0].cbr_rules) > 0) ? [

    # returns a set containing rules and the bucket to which the rules to be applied to
    for pair in setproduct(var.bucket_configs[0].cbr_rules, toset(local.bucket_name)) : {
      cbr_rule_block = pair[0]
      bucket_name    = pair[1]
    }
  ] : []
}

##############################################################################
# Context Based Restrictions
##############################################################################

module "bucket_cbr_rule" {
  # generates a map with bucket name as key and cbr rule for bucket as value
  for_each = {
    for bucket_rule in local.cbr_rules : bucket_rule.bucket_name => bucket_rule
  }

  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-rule-module?ref=v1.2.0"
  rule_description = each.value.cbr_rule_block.description
  enforcement_mode = each.value.cbr_rule_block.enforcement_mode
  rule_contexts    = each.value.cbr_rule_block.rule_contexts

  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = each.value.cbr_rule_block.account_id
        operator = "stringEquals"
      },
      {
        name     = "resource"
        value    = each.value.bucket_name
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = local.cos_instance_guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
      }
    ],
    tags = each.value.cbr_rule_block.tags
  }]
  operations = each.value.cbr_rule_block.operations == null ? [] : each.value.cbr_rule_block.operations
}
