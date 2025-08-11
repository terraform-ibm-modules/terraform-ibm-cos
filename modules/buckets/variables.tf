##############################################################################
# Common variables
##############################################################################

##############################################################################
# COS bucket configs
##############################################################################
variable "bucket_configs" {
  type = list(object({
    access_tags                   = optional(list(string), [])
    add_bucket_name_suffix        = optional(bool, false)
    bucket_name                   = string
    kms_encryption_enabled        = optional(bool, true)
    kms_guid                      = optional(string, null)
    kms_key_crn                   = optional(string, null)
    skip_iam_authorization_policy = optional(bool, false)
    management_endpoint_type      = optional(string, "public")
    cross_region_location         = optional(string, null)
    storage_class                 = optional(string, "smart")
    region_location               = optional(string, null)
    resource_instance_id          = string
    force_delete                  = optional(bool, true)
    single_site_location          = optional(string, null)
    hard_quota                    = optional(number, null)
    expire_filter_prefix          = optional(string, null)
    archive_filter_prefix         = optional(string, null)
    object_locking_enabled        = optional(bool, false)
    object_lock_duration_days     = optional(number, 0)
    object_lock_duration_years    = optional(number, 0)

    activity_tracking = optional(object({
      read_data_events  = optional(bool, true)
      write_data_events = optional(bool, true)
      management_events = optional(bool, true)
    }))
    archive_rule = optional(object({
      enable = optional(bool, false)
      days   = optional(number, 20)
      type   = optional(string, "Glacier")
    }))
    expire_rule = optional(object({
      enable = optional(bool, false)
      days   = optional(number, 365)
    }))
    noncurrent_expire = optional(object({
      enable = optional(bool, false)
      days   = optional(number, 365)
      prefix = optional(string, "nc-exp")
    }))
    abort_multipart = optional(object({
      enable = optional(bool, false)
      days   = optional(number, 365)
      prefix = optional(string, "ab-mp")
    }))
    metrics_monitoring = optional(object({
      usage_metrics_enabled   = optional(bool, true)
      request_metrics_enabled = optional(bool, true)
      metrics_monitoring_crn  = optional(string, null)
    }))
    object_versioning = optional(object({
      enable = optional(bool, false)
    }))
    retention_rule = optional(object({
      default   = optional(number, 90)
      maximum   = optional(number, 350)
      minimum   = optional(number, 90)
      permanent = optional(bool, false)
    }))
    replication = optional(object({
      enable      = optional(bool, true)
      rule_id     = optional(string, "test-1")
      prefix      = optional(string, "test-rp")
      priority    = optional(number, 1)
      bucket_name = optional(string, "rep-buc")
    }))
    cbr_rules = optional(list(object({
      description = string
      account_id  = string
      rule_contexts = list(object({
        attributes = optional(list(object({
          name  = string
          value = string
      }))) }))
      enforcement_mode = string
      tags = optional(list(object({
        name  = string
        value = string
      })), [])
      operations = optional(list(object({
        api_types = list(object({
          api_type_id = string
        }))
      })))
    })), [])

  }))
  description = "The Object Storage bucket configurations."

  validation {
    condition = alltrue([for bucket_config_1 in var.bucket_configs : length([
      for bucket_config_2 in var.bucket_configs : bucket_config_2
      if bucket_config_2.kms_encryption_enabled && !bucket_config_2.skip_iam_authorization_policy && bucket_config_2.resource_instance_id == bucket_config_1.resource_instance_id && bucket_config_2.kms_guid == bucket_config_1.kms_guid
    ]) == 1 if bucket_config_1.kms_encryption_enabled && !bucket_config_1.skip_iam_authorization_policy])
    error_message = "Duplicate authentication policy found in the bucket configuration."
  }

}
