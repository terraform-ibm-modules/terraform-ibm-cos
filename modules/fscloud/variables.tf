##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

##############################################################################
# COS instance variables
##############################################################################

variable "create_cos_instance" {
  description = "Set as true to create a new Cloud Object Storage instance."
  type        = bool
  default     = true
}

variable "create_resource_key" {
  description = "Set as true to create a new resource key for the Cloud Object Storage instance."
  type        = bool
  default     = false
}

variable "generate_hmac_credentials" {
  description = "Set as true to generate an HMAC key in the resource key. Only used when create_resource_key is `true`."
  type        = bool
  default     = false
}

variable "resource_key_name" {
  description = "The name of the resource key to be created."
  type        = string
  default     = "cos-resource-key"
}

variable "resource_key_role" {
  description = "The role you want to be associated with your new resource key. Valid roles are 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer'."
  type        = string
  default     = "Manager"
}

variable "cos_instance_name" {
  description = "The name to give the cloud object storage instance that will be provisioned by this module. Only required if 'create_cos_instance' is true."
  type        = string
  default     = null
}

variable "cos_tags" {
  description = "Optional list of tags to be added to cloud object storage instance. Only used if 'create_cos_instance' it true."
  type        = list(string)
  default     = []
}

variable "existing_cos_instance_id" {
  description = "The ID of an existing cloud object storage instance. Required if 'var.create_cos_instance' is false."
  type        = string
  default     = null
}

variable "cos_plan" {
  description = "Plan to be used for creating cloud object storage instance. Only used if 'create_cos_instance' it true."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard"], var.cos_plan)
    error_message = "The specified cos_plan is not a valid selection!"
  }
}

##############################################################################
# COS bucket variables
##############################################################################
variable "bucket_configs" {
  type = list(object({
    access_tags                   = optional(list(string), [])
    bucket_name                   = string
    kms_encryption_enabled        = optional(bool, true)
    kms_guid                      = optional(string, null)
    kms_key_crn                   = string
    skip_iam_authorization_policy = optional(bool, false)
    management_endpoint_type      = string
    cross_region_location         = optional(string, null)
    storage_class                 = optional(string, "smart")
    region_location               = optional(string, null)
    resource_instance_id          = optional(string, null)
    force_delete                  = optional(bool, true)
    single_site_location          = optional(string, null)
    hard_quota                    = optional(number, null)

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
  default     = []

  validation {
    condition     = length([for bucket_config in var.bucket_configs : true if contains([true], bucket_config.kms_encryption_enabled)]) == length(var.bucket_configs)
    error_message = "The FSCloud submodule mandates that kms_encryption_enabled is set to true for all buckets in bucket_configs input variable value."
  }
}



##############################################################
# Context-based restriction (CBR)
##############################################################

variable "instance_cbr_rules" {
  type = list(object({
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
  }))
  description = "(Optional, list) List of CBR rule to create for the instance"
  default     = []
  # Validation happens in the rule module
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the cos instance created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details"
  default     = []
}
