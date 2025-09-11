##############################################################################
# terraform-ibm-cos
#
# Create COS buckets from bucket_configs
##############################################################################

locals {
  access_policy = [
    for bucket_config in var.bucket_configs : {
      "cos_guid" : coalescelist(split(":", bucket_config.resource_instance_id))[7]
      "kms_guid" : bucket_config.kms_guid,
      "type" : coalescelist(split(":", bucket_config.kms_key_crn))[4]
      "kms_key_id" : coalescelist(split(":", bucket_config.kms_key_crn))[9]
      "kms_account_id" : split("/", coalescelist(split(":", bucket_config.resource_instance_id))[6])[1]
    } if bucket_config.kms_encryption_enabled && !bucket_config.skip_iam_authorization_policy
  ]
}

# Create IAM Authorization Policy to allow COS to access KMS for the encryption key
resource "ibm_iam_authorization_policy" "policy" {
  count                       = length(local.access_policy)
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.access_policy[count.index]["cos_guid"]
  roles                       = ["Reader"]
  description                 = "Allow the COS instance ${local.access_policy[count.index]["cos_guid"]} to read the ${local.access_policy[count.index]["type"]} key ${local.access_policy[count.index]["kms_key_id"]} from the instance ${local.access_policy[count.index]["kms_guid"]}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.access_policy[count.index]["type"]
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.access_policy[count.index]["kms_account_id"]
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.access_policy[count.index]["kms_guid"]
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.access_policy[count.index]["kms_key_id"]
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.policy]
  count      = length(local.access_policy) > 0 ? 1 : 0
  # workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
  create_duration = "30s"
  # workaround for https://github.com/terraform-ibm-modules/terraform-ibm-cos/issues/672
  destroy_duration = "30s"
}

module "buckets" {
  for_each = {
    for index, bucket in var.bucket_configs :
    bucket.bucket_name => bucket
  }
  depends_on                    = [time_sleep.wait_for_authorization_policy]
  source                        = "../../"
  bucket_name                   = each.value.bucket_name
  create_cos_instance           = false
  add_bucket_name_suffix        = each.value.add_bucket_name_suffix
  skip_iam_authorization_policy = true
  existing_cos_instance_id      = each.value.resource_instance_id
  region                        = each.value.region_location

  cross_region_location                       = each.value.cross_region_location
  single_site_location                        = each.value.single_site_location
  bucket_storage_class                        = each.value.storage_class
  existing_kms_instance_guid                  = each.value.kms_guid
  kms_key_crn                                 = each.value.kms_key_crn
  kms_encryption_enabled                      = each.value.kms_encryption_enabled
  management_endpoint_type_for_bucket         = each.value.management_endpoint_type
  force_delete                                = each.value.force_delete
  hard_quota                                  = each.value.hard_quota
  expire_filter_prefix                        = each.value.expire_rule.expire_filter_prefix
  archive_filter_prefix                       = each.value.archive_rule.archive_filter_prefix
  noncurrent_version_expiration_filter_prefix = each.value.noncurrent_version_expiration_rule.noncurrent_version_expiration_filter_prefix
  object_locking_enabled                      = each.value.object_locking_enabled
  object_lock_duration_days                   = each.value.object_lock_duration_days
  object_lock_duration_years                  = each.value.object_lock_duration_years

  access_tags = can(each.value.access_tags) ? each.value.access_tags : []

  activity_tracker_read_data_events  = can(each.value.activity_tracking.read_data_events) ? each.value.activity_tracking.read_data_events : true
  activity_tracker_write_data_events = can(each.value.activity_tracking.write_data_events) ? each.value.activity_tracking.write_data_events : true
  activity_tracker_management_events = can(each.value.activity_tracking.management_events) ? each.value.activity_tracking.management_events : true

  archive_days = can(each.value.archive_rule.days) ? (each.value.archive_rule.enable ? each.value.archive_rule.days : null) : null
  archive_type = can(each.value.archive_rule.type) ? each.value.archive_rule.type : "Glacier"

  expire_days = can(each.value.expire_rule.days) ? (each.value.expire_rule.enable ? each.value.expire_rule.days : null) : null

  noncurrent_version_expiration_days = can(each.value.noncurrent_version_expiration_rule.days) ? (each.value.noncurrent_version_expiration_rule.enable ? each.value.noncurrent_version_expiration_rule.days : null) : null

  request_metrics_enabled = can(each.value.metrics_monitoring.request_metrics_enabled) ? each.value.metrics_monitoring.request_metrics_enabled : true
  usage_metrics_enabled   = can(each.value.metrics_monitoring.usage_metrics_enabled) ? each.value.metrics_monitoring.usage_metrics_enabled : true
  monitoring_crn          = can(each.value.metrics_monitoring.metrics_monitoring_crn) ? each.value.metrics_monitoring.metrics_monitoring_crn : null

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
