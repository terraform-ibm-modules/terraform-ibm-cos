##############################################################################
# terraform-ibm-cos
#
# Create COS buckets from bucket_configs
##############################################################################

locals {
  access_policy = [
    for bucket_config in var.bucket_configs : {
      "cos_guid" : element(split(":", bucket_config.resource_instance_id), length(split(":", bucket_config.resource_instance_id)) - 3),
      "kms_guid" : bucket_config.kms_guid,
      "type" : can(regex(".*kms.*", bucket_config.kms_key_crn)) ? "kms" : "hs-crypto"
    } if bucket_config.kms_encryption_enabled && !bucket_config.skip_iam_authorization_policy
  ]
}

# Create IAM Authorization Policy to allow COS to access KMS for the encryption key
resource "ibm_iam_authorization_policy" "policy" {
  count                       = length(local.access_policy)
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.access_policy[count.index]["cos_guid"]
  target_service_name         = local.access_policy[count.index]["type"]
  target_resource_instance_id = local.access_policy[count.index]["kms_guid"]
  roles                       = ["Reader"]
  description                 = "Allow the COS instance with GUID ${local.access_policy[count.index]["cos_guid"]} reader access to the ${local.access_policy[count.index]["type"]} instance GUID ${local.access_policy[count.index]["kms_guid"]}"
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.policy]
  count           = length(local.access_policy) > 0 ? 1 : 0
  create_duration = "30s"
}

module "buckets" {
  for_each = {
    for index, bucket in var.bucket_configs :
    bucket.bucket_name => bucket
  }
  source                        = "../../"
  bucket_name                   = each.value.bucket_name
  create_cos_instance           = false
  add_bucket_name_suffix        = each.value.add_bucket_name_suffix
  skip_iam_authorization_policy = true
  existing_cos_instance_id      = each.value.resource_instance_id
  region                        = each.value.region_location

  cross_region_location               = each.value.cross_region_location
  single_site_location                = each.value.single_site_location
  bucket_storage_class                = each.value.storage_class
  existing_kms_instance_guid          = each.value.kms_guid
  kms_key_crn                         = each.value.kms_key_crn
  kms_encryption_enabled              = each.value.kms_encryption_enabled
  management_endpoint_type_for_bucket = each.value.management_endpoint_type
  force_delete                        = each.value.force_delete
  hard_quota                          = each.value.hard_quota
  object_locking_enabled              = each.value.object_locking_enabled
  object_lock_duration_days           = each.value.object_lock_duration_days
  object_lock_duration_years          = each.value.object_lock_duration_years

  access_tags = can(each.value.access_tags) ? each.value.access_tags : []

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

locals {
  bucket_rule_ids = flatten([
    for bucket_name, bucket_rule in module.buckets :
    bucket_rule.cbr_rule_ids
  ])
}
