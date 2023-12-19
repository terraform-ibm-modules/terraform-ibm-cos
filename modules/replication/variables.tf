variable "source_bucket_config" {
  type = object({
    access_tags              = optional(list(string), [])
    bucket_name              = string
    kms_encryption_enabled   = optional(bool, true)
    kms_guid                 = optional(string, null)
    kms_key_crn              = optional(string, null)
    management_endpoint_type = optional(string, "public")
    cross_region_location    = optional(string, null)
    storage_class            = optional(string, "smart")
    region_location          = optional(string, null)
    resource_group_id        = string
    resource_instance_id     = string

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

  })
  description = "Cloud Object Storage replication source bucket configuration"
}

variable "source_replication_rules" {
  type = list(object({
# rule_id- (Optional, String) The rule id.
# enable- (Required, Bool) Specifies whether the rule is enabled. Specify true for Enabling it or false for Disabling it.
# prefix- (Optional, String) An object key name prefix that identifies the subset of objects to which the rule applies.
# priority- (Optional, Int) A priority is associated with each rule. The rule will be applied in a higher priority if there are multiple rules configured. The higher the number, the higher the priority
# deletemarker_replication_status- (Optional, Bool) Specifies whether Object storage replicates delete markers.Specify true for Enabling it or false for Disabling it.
    rule_id = optional(string)
    enable = optional(bool)
    prefix = optional(string)
    priority = optional(number)
    deletemarker_replication_status = optional(bool)
  }))
  description = "List of rules for replication from source to target, default all excluding delete requests"
}

variable "target_bucket_config" {
  type = object({
    access_tags              = optional(list(string), [])
    bucket_name              = string
    kms_encryption_enabled   = optional(bool, true)
    kms_guid                 = optional(string, null)
    kms_key_crn              = optional(string, null)
    management_endpoint_type = optional(string, "public")
    cross_region_location    = optional(string, null)
    storage_class            = optional(string, "smart")
    region_location          = optional(string, null)
    resource_group_id        = string
    resource_instance_id     = string

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

  })
  description = "Cloud Object Storage replication target bucket configuration"
}

variable "target_replication_rules" {
  type = list(object({
    rule_id = optional(string)
    enable = optional(bool)
    prefix = optional(string)
    priority = optional(number)
    deletemarker_replication_status = optional(bool)
  }))
  description = "List of rules for replication from target back to source, default none"
  default     = []
}
