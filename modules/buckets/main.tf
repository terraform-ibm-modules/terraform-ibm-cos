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
  encryption_enabled    = true # can(each.value.kms_key_crn)

  activity_tracker_crn = can(each.value.activity_tracking.activity_tracker_crn) ? each.value.activity_tracking.activity_tracker_crn : null

  archive_days = can(each.value.archive_rule.days) ? (each.value.archive_rule.enable ? each.value.archive_rule.days : null) : null
  archive_type = can(each.value.archive_rule.type) ? each.value.archive_rule.type : "Glacier"

  expire_days = can(each.value.expire_rule.days) ? (each.value.expire_rule.enable ? each.value.expire_rule.days : null) : null

  sysdig_crn = can(each.value.metrics_monitoring.metrics_monitoring_crn) ? each.value.metrics_monitoring.metrics_monitoring_crn : null

  object_versioning_enabled = can(each.value.object_versioning.enable) ? each.value.object_versioning.enable : false

  retention_enabled   = can(each.value.retention_rule.default) || can(each.value.retention_rule.maximum) || can(each.value.retention_rule.minimum) || can(each.value.retention_rule.permanent) ? true : false
  retention_default   = can(each.value.retention_rule.default) ? each.value.retention_rule.default : 90
  retention_maximum   = can(each.value.retention_rule.maximum) ? each.value.retention_rule.maximum : 350
  retention_minimum   = can(each.value.retention_rule.minimum) ? each.value.retention_rule.minimum : 90
  retention_permanent = can(each.value.retention_rule.permanent) ? each.value.retention_rule.permanent : false

  bucket_cbr_rules = each.value.cbr_rules
}
