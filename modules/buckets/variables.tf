##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

variable "region" {
  description = "The region to provision the bucket. If you pass a value for this, do not pass one for var.cross_region_location."
  type        = string
  default     = "us-south"
}

##############################################################################
# COS instance variables
##############################################################################

variable "create_cos_instance" {
  description = "Set as true to create a new Cloud Object Storage instance."
  type        = bool
  default     = true
}

variable "create_hmac_key" {
  description = "Set as true to create a new HMAC key for the Cloud Object Storage instance."
  type        = bool
  default     = true
}

variable "resource_key_existing_serviceid_crn" {
  description = "CRN of existing serviceID to bind with resource key to be created. If null a new ServiceID is created for the resource key."
  type        = string
  default     = null
}

variable "hmac_key_name" {
  description = "The name of the hmac key to be created."
  type        = string
  default     = "hmac-cos-key"
}

variable "hmac_key_role" {
  description = "The role you want to be associated with your new hmac key. Valid roles are 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer'."
  type        = string
  default     = "Manager"
}

variable "cos_instance_name" {
  description = "The name to give the cloud object storage instance that will be provisioned by this module. Only required if 'create_cos_instance' is true."
  type        = string
  default     = null
}

variable "cos_location" {
  description = "Location to provision the cloud object storage instance. Only used if 'create_cos_instance' is true."
  type        = string
  default     = "global"
}

variable "cos_plan" {
  description = "Plan to be used for creating cloud object storage instance. Only used if 'create_cos_instance' it true."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "lite"], var.cos_plan)
    error_message = "The specified cos_plan is not a valid selection!"
  }
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

##############################################################################
# COS bucket variables
##############################################################################

variable "create_cos_bucket" {
  description = "Set as true to create a new Cloud Object Storage bucket"
  type        = bool
  default     = true
}

variable "cross_region_location" {
  description = "Specify the cross-regional bucket location. Supported values are 'us', 'eu', and 'ap'. If you pass a value for this, ensure to set the value of var.region to null."
  type        = string
  default     = null

  validation {
    condition     = var.cross_region_location == null || can(regex("us|eu|ap", var.cross_region_location))
    error_message = "Variable 'cross_region_location' must be 'us' or 'eu', 'ap', or 'null'."
  }
}

variable "bucket_storage_class" {
  type        = string
  description = "the storage class of the newly provisioned COS bucket. Only required if 'create_cos_bucket' is true. Supported values are 'standard', 'vault', 'cold', and 'smart'."
  default     = "standard"

  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$", var.bucket_storage_class))
    error_message = "Variable 'bucket_storage_class' must be 'standard', 'vault', 'cold', or 'smart'."
  }
}

variable "retention_enabled" {
  description = "Retention enabled for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = bool
  default     = true
}

variable "retention_default" {
  description = "Specifies default duration of time an object that can be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_default > 0 && var.retention_default < 365243
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_maximum" {
  description = "Specifies maximum duration of time an object that can be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 350
  validation {
    condition     = var.retention_maximum > 0 && var.retention_maximum < 365243
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_minimum" {
  description = "Specifies minimum duration of time an object must be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_minimum > 0 && var.retention_minimum < 365243
    error_message = "The specified duration for retention minimum period is not a valid selection!"
  }
}

variable "retention_permanent" {
  description = "Specifies a permanent retention status either enable or disable for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = bool
  default     = false
}

variable "object_versioning_enabled" {
  description = "Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. Only used if 'create_cos_bucket' is true."
  type        = bool
  default     = false
}

variable "archive_days" {
  description = "Specifies the number of days when the archive rule action takes effect. Only used if 'create_cos_bucket' is true. This must be set to null when when using var.cross_region_location as archive data is not supported with this feature."
  type        = number
  default     = 90
}

variable "archive_type" {
  description = "Specifies the storage class or archive type to which you want the object to transition. Only used if 'create_cos_bucket' is true."
  type        = string
  default     = "Glacier"
  validation {
    condition     = contains(["Glacier", "Accelerated"], var.archive_type)
    error_message = "The specified archive_type is not a valid selection!"
  }
}

variable "expire_days" {
  description = "Specifies the number of days when the expire rule action takes effect. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 365
}

variable "activity_tracker_crn" {
  type        = string
  description = "Activity tracker crn for COS bucket (Optional)"
  default     = null
}

variable "sysdig_crn" {
  type        = string
  description = "Sysdig Monitoring crn for COS bucket (Optional)"
  default     = null
}

##############################################################################
# COS bucket encryption variables
##############################################################################

variable "existing_kms_instance_guid" {
  description = "The GUID of the Key Protect instance in which the key specified in var.kms_key_crn is coming from. Required if var.create_cos_instance is true in order to create an IAM Access Policy to allow Key protect to access the newly created COS instance."
  type        = string
  default     = null
}

variable "encryption_enabled" {
  description = "Set as true to use Key Protect encryption to encrypt data in COS bucket (only applicable when var.create_cos_bucket is true)."
  type        = bool
  default     = true
}

variable "kms_key_crn" {
  description = "CRN of the Key Protect Key to use to encrypt the data in the COS Bucket. Required if var.encryption_enabled and var.create_cos_bucket are true."
  type        = string
  default     = null
}

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

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "bucket_cbr_rules" {
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
  description = "(Optional, list) List of CBR rules to create for the bucket"
  default     = []
  # Validation happens in the rule module
}

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
  description = "(Optional, list) List of CBR rules to create for the instance"
  default     = []
  # Validation happens in the rule module
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits the COS instance created to read the encryption key from the Key Protect instance in `existing_kms_instance_guid`. WARNING: An authorization policy must exist before an encrypted bucket can be created"
  default     = false
}

variable "bucket_names" {
  type        = list(string)
  description = "List of buckets to be created"
  default     = []
}
