##############################################################################
# Secure Regional Bucket
##############################################################################

locals {
  bucket_config = [{
    access_tags                   = var.bucket_access_tags
    bucket_name                   = var.bucket_name
    kms_encryption_enabled        = var.kms_encryption_enabled
    add_bucket_name_suffix        = var.add_bucket_name_suffix
    kms_guid                      = var.existing_kms_instance_guid
    kms_key_crn                   = var.kms_key_crn
    skip_iam_authorization_policy = var.skip_iam_authorization_policy
    management_endpoint_type      = var.management_endpoint_type_for_bucket
    region_location               = var.region
    storage_class                 = var.bucket_storage_class
    force_delete                  = var.force_delete
    hard_quota                    = var.hard_quota

    activity_tracking = var.activity_tracker_crn != null ? {
      read_data_events     = true
      write_data_events    = true
      activity_tracker_crn = var.activity_tracker_crn
    } : null
    archive_rule = var.archive_days != null ? {
      enable = true
      days   = var.archive_days
      type   = var.archive_type
    } : null
    expire_rule = var.expire_days != null ? {
      enable = true
      days   = var.expire_days
    } : null
    metrics_monitoring = var.sysdig_crn != null ? {
      usage_metrics_enabled   = true
      request_metrics_enabled = true
      metrics_monitoring_crn  = var.sysdig_crn
    } : null
    object_versioning = {
      enable = var.object_versioning_enabled
    }
    retention_rule = var.retention_enabled ? {
      default   = var.retention_default
      maximum   = var.retention_maximum
      minimum   = var.retention_minimum
      permanent = var.retention_permanent
    } : null
    cbr_rules = var.bucket_cbr_rules

  }]
}

module "cos" {
  source                   = "../../modules/fscloud"
  resource_group_id        = null
  create_cos_instance      = false
  existing_cos_instance_id = var.existing_cos_instance_id
  bucket_configs           = local.bucket_config
}
