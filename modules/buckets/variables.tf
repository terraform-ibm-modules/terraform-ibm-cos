##############################################################################
# Common variables
##############################################################################
variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

##############################################################################
# COS bucket configs
##############################################################################
variable "bucket_configs" {
  type = list(object({
    bucket_name           = string
    kms_key_crn           = optional(string, null)
    cross_region_location = optional(string, null)
    storage_class         = optional(string, "smart")
    region_location       = optional(string, null)
    resource_instance_id  = optional(string, null)

    activity_tracking = optional(object({
      read_data_events     = optional(bool, true)
      write_data_events    = optional(bool, true)
      activity_tracker_crn = optional(string, null)
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
  description = "Cloud Object Storage bucket configurations"
  default     = null
}
