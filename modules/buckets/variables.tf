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
  description = "Cloud Object Storage bucket configuration"
  default     = null

  #  validation {
  #    condition     = var.bucket_configs.retention_rule.retention_default > 0 && var.bucket_configs.retention_rule.retention_default < 365243
  #    error_message = "The specified duration for retention default period is not a valid selection"
  #  }

  #  validation {
  #    condition     = var.bucket_configs.retention_rule.retention_maximum > 0 && var.bucket_configs.retention_rule.retention_maximum < 365243
  #    error_message = "The specified duration for retention maximum period is not a valid selection"
  #  }

  #  validation {
  #    condition     = var.bucket_configs.retention_rule.retention_minimum > 0 && var.bucket_configs.retention_rule.retention_minimum < 365243
  #    error_message = "The specified duration for retention minimum period is not a valid selection"
  #  }

  #  validation {
  #    condition     = contains(["Glacier", "Accelerated"], var.bucket_configs.archive_rule.type)
  #    error_message = "The specified var.bucket_configs.archive_rule.type is not a valid selection"
  #  }

  #  validation {
  #    condition     = can(regex("^standard$|^vault$|^cold$|^smart$", var.bucket_storage_class))
  #    error_message = "Variable 'bucket_storage_class' must be 'standard', 'vault', 'cold', or 'smart'."
  #  }

  #  validation {
  #    condition     = var.bucket_configs.cross_region_location == null || can(regex("us|eu|ap", var.bucket_configs.cross_region_location))
  #    error_message = "Variable 'cross_region_location' must be 'us' or 'eu', 'ap', or 'null'."
  #  }

}
