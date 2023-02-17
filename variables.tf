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

variable "service_endpoints" {
  description = "(Deprecated) Will be removed in the next major release"
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

variable "bucket_name" {
  type        = string
  description = "The name to give the newly provisioned COS bucket. Only required if 'create_cos_bucket' is true."
  default     = null
}

variable "bucket_endpoint" {
  description = "The type of endpoint to use for the bucket. (public, private, direct)"
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private", "direct"], var.bucket_endpoint)
    error_message = "The specified bucket_endpoint is not a valid selection!"
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

variable "existing_key_protect_instance_guid" {
  description = "The GUID of the Key Protect instance in which the key specified in var.key_protect_key_crn is coming from. Required if var.create_cos_instance is true in order to create an IAM Access Policy to allow Key protect to access the newly created COS instance."
  type        = string
  default     = null
}

variable "encryption_enabled" {
  description = "Set as true to use Key Protect encryption to encrypt data in COS bucket (only applicable when var.create_cos_bucket is true)."
  type        = bool
  default     = true
}

variable "key_protect_key_crn" {
  description = "CRN of the Key Protect Key to use to encrypt the data in the COS Bucket. Required if var.encryption_enabled and var.create_cos_bucket are true."
  type        = string
  default     = null
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
