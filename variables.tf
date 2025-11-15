##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID for the Object Storage instance. Required if `create_cos_instance` is set to `true`."
  default     = null
  validation {
    condition     = var.create_cos_instance == false || var.resource_group_id != null
    error_message = "If `var.create_cos_instance` is `true`, then provide a value for `var.resource_group_id` to create an Object Storage instance."
  }
}

##############################################################################
# COS instance variables
##############################################################################

variable "create_cos_instance" {
  description = "Whether to create an IBM Cloud Object Storage instance."
  type        = bool
  default     = true
}

# `name` is the terraform static reference to the object in the list
# `key_name` is the IBM Cloud resource key name
# `name` MUST not be dynamic, so that it is known at plan time
# if `key_name` is not specified, `name` is used for the `key_name`
# `key_name` can be a dynamic reference created during apply
variable "resource_keys" {
  description = "The definition of the resource keys to generate. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key)."
  type = list(object({
    name                      = string
    key_name                  = optional(string, null)
    generate_hmac_credentials = optional(bool, false)
    role                      = optional(string, "Reader")
    service_id_crn            = optional(string, null)
  }))
  default = []
  validation {
    # From: https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key
    # Service roles (for Object Storage) https://cloud.ibm.com/iam/roles
    # Reader, Writer, Manager, Content Reader, Object Reader, Object Writer, NONE
    condition = alltrue([
      for key in var.resource_keys : contains(["Writer", "Reader", "Manager", "Content Reader", "Object Reader", "Object Writer", "NONE"], key.role)
    ])
    error_message = "`resource_keys` role must be one of the following: `Writer', `Reader`, `Manager`, `Content Reader`, `Object Reader`, `Object Writer`, or `NONE`. Reference https://cloud.ibm.com/iam/roles and `Object Storage`"
  }
}

variable "cos_instance_name" {
  description = "The name for the IBM Cloud Object Storage instance provisioned by this module. Required if `create_cos_instance` is set to `true`."
  type        = string
  default     = null
  validation {
    condition     = var.create_cos_instance == false || var.cos_instance_name != null
    error_message = "If `var.create_cos_instance` is set to `true`, then you must provide a value for `var.cos_instance_name`."
  }
}

variable "cos_plan" {
  description = "The plan to use when Object Storage instances are created. Possible values are `standard` or `cos-one-rate-plan`. Required if `create_cos_instance` is set to `true`. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision)."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "cos-one-rate-plan"], var.cos_plan)
    error_message = "The value is not valid. Possible values are `standard` or `cos-one-rate-plan`."
  }
}

variable "cos_tags" {
  description = "A list of tags to apply to the Object Storage instance."
  type        = list(string)
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Object Storage instance created by the module. [Learn more](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial)."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression `\"[\\w\\-_\\.]+:[\\w\\-_\\.]+\"`. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits)."
  }
}

variable "existing_cos_instance_id" {
  description = "The ID of an existing Object Storage instance. Required if `create_cos_instance` is set to `false`."
  type        = string
  default     = null

  validation {
    condition     = var.create_cos_instance == true || var.existing_cos_instance_id != null
    error_message = "If `var.create_cos_instance` is set to `false`, then provide a value for `var.existing_cos_instance_id` to create buckets."
  }
}

##############################################################################
# COS bucket variables
##############################################################################

variable "region" {
  description = "The region to provision the bucket. If specified, set `cross_region_location` and `single_site_location` to `null`."
  type        = string
  default     = "us-south"
}

variable "create_cos_bucket" {
  description = "Whether to create an Object Storage bucket."
  type        = bool
  default     = true
  validation {
    condition     = !(var.create_cos_instance == false && var.create_cos_bucket == false)
    error_message = "`create_cos_instance` and `create_cos_bucket` can't both be set to `false`. At least one must be set to `true`."
  }
}

variable "cross_region_location" {
  description = "Specify the cross-region bucket location. Possible values are `us`, `eu`, or `ap`. If specified, set `region` and `single_site_location` to `null`."
  type        = string
  default     = null

  validation {
    condition     = var.cross_region_location == null || can(regex("us|eu|ap", var.cross_region_location))
    error_message = "The value isn't valid. Possible values are 'us', 'eu', 'ap', or 'null'."
  }
  validation {
    condition     = var.cos_plan != "cos-one-rate-plan" || var.cross_region_location == null
    error_message = "If `var.cos_plan` is 'cos-one-rate-plan', then `var.cross_region_location` can't be set. The one rate plan doesn't support cross-region buckets."
  }
  validation {
    condition = var.create_cos_bucket == false || (
      length(compact([var.cross_region_location, var.region, var.single_site_location])) == 1
    )
    error_message = "If `var.create_cos_bucket` is set to `true`, then a value must be provided for `var.cross_region_location`, `var.region`, or `var.single_site_location`. Only one of those three variables can be set."
  }
}

variable "bucket_name" {
  type        = string
  description = "The name for the Object Storage bucket. Applies only if `create_cos_bucket` is set to `true`."
  default     = null
  validation {
    condition     = var.create_cos_bucket == false || var.bucket_name != null
    error_message = "If `var.create_cos_bucket` is set to `true`, a value must be provided for `var.bucket_name`."
  }
}

variable "allow_public_access_to_buckets" {
  type = bool
  description = "Set it to `true` to allow the cos bucket to be publically accessible."
  default = false
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Whether to add a randomly generated 4-character suffix to the bucket name."
  default     = true
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the bucket. Applies only if `create_cos_bucket` is set to `true`. Possible values are `standard`, `vault`, `cold`, `smart`, or `onerate_active`."
  default     = "standard"

  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$|^onerate_active", var.bucket_storage_class))
    error_message = " The value isn't valid. Possible values are 'standard', 'vault', 'cold', 'smart', or 'onerate_active'."
  }
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to manage the bucket. Possible values are `public`, `private`, or `direct`."
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The value isn't valid. Possible values are `public`, `private`, or `direct`."
  }
}

# Where is retention (immuatble object storage) supported
# https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability#service-availability
variable "retention_enabled" {
  description = "Whether retention for the Object Storage bucket is enabled. Applies only if `create_cos_bucket` is set to `true`."
  type        = bool
  default     = false
  validation {
    condition     = var.cross_region_location == null || (var.cross_region_location == "us" || !var.retention_enabled)
    error_message = "Retention is currently only supported in the `US` location for cross-region buckets."
  }
}

variable "retention_default" {
  description = "The number of days that an object can remain unmodified in an Object Storage bucket. Applies only if `create_cos_bucket` is set to `true`."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_default == null ? true : (var.retention_default >= 0 && var.retention_default <= 365243)
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_maximum" {
  description = "The maximum number of days that an object can be kept unmodified in the bucket. Applies only if `create_cos_bucket` is set to `true`."
  type        = number
  default     = 350
  validation {
    condition     = (var.retention_maximum == null ? true : (var.retention_maximum >= 0 && var.retention_maximum <= 365243))
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_minimum" {
  description = "The minimum number of days that an object must be kept unmodified in the bucket. Applies only if `create_cos_bucket` is set to `true`."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_minimum == null ? true : (var.retention_minimum >= 0 && var.retention_minimum <= 365243)
    error_message = "The specified duration for retention minimum period is not a valid selection!"
  }
}

variable "retention_permanent" {
  description = "Whether permanent retention status is enabled for the Object Storage bucket. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-immutable). Applies only if `create_cos_bucket` is set to `true`."
  type        = bool
  default     = false
}

variable "object_locking_enabled" {
  description = "Whether to create an object lock configuration. If set to true, `object_versioning_enabled` and `create_cos_bucket` must also be set to `true`."
  type        = bool
  default     = false

  validation {
    condition     = var.object_versioning_enabled == true || !var.object_locking_enabled
    error_message = "Object locking requires object versioning. Make sure `object_versioning_enabled` is set to `true`."
  }
}

variable "object_lock_duration_days" {
  description = "The number of days for the object lock duration. If you specify a number of days, do not specify a value for `object_lock_duration_years`. Applies only if `create_cos_bucket` is set to `true`."
  type        = number
  default     = 0
  validation {
    condition     = !(var.object_locking_enabled && var.object_lock_duration_days != 0 && var.object_lock_duration_years != 0)
    error_message = "Object lock duration days and years can't both be set when object locking is enabled. Make sure `object_lock_duration_years` is not set."
  }

  validation {
    condition     = !var.object_locking_enabled || var.object_lock_duration_days != 0 || var.object_lock_duration_years != 0
    error_message = "Object lock duration days or years must be set when object locking is enabled. Provide a value for `object_lock_duration_days` or `object_lock_duration_years`."
  }
}

variable "object_lock_duration_years" {
  description = "The number of years for the object lock duration. If you specify a number of years, do not specify a value for `object_lock_duration_days`. Applies only if `create_cos_bucket` is set to `true`."
  type        = number
  default     = 0
}

variable "object_versioning_enabled" {
  description = "Whether to enable object versioning to keep multiple versions of an object in a bucket. Can't be used with retention rule. Applies only if `create_cos_bucket` is set to `true`."
  type        = bool
  default     = false
}

variable "archive_days" {
  description = "The number of days before the `archive_type` rule action takes effect. Applies only if `create_cos_bucket` is set to `true`. Set to `null` if you specify a bucket location in `cross_region_location` because archive data is not supported with cross-region buckets. If null is passed, no lifecycle configuration will be added for bucket archival."
  type        = number
  default     = null
  validation {
    condition     = var.create_cos_bucket == false || (var.cross_region_location == null || var.archive_days == null)
    error_message = "If `var.cross_region_location` is set, then `var.archive_days` cannot be set."
  }
}

variable "archive_type" {
  description = "The storage class or archive type to which you want the object to transition. Possible values are `Glacier` or `Accelerated`. Applies only if `create_cos_bucket` is set to `true`."
  type        = string
  default     = "Glacier"
  validation {
    condition     = contains(["Glacier", "Accelerated"], var.archive_type)
    error_message = "The value isn't valid. Possible values are `Glacier` or `Accelerated`."
  }
}

variable "expire_days" {
  description = "The number of days before the expire rule action takes effect. Applies only if `create_cos_bucket` is set to `true`. If null is passed, no lifecycle configuration will be added for bucket expiration."
  type        = number
  default     = null
}

variable "request_metrics_enabled" {
  type        = bool
  description = "If set to `true`, all Object Storage bucket request metrics are sent to Cloud Monitoring."
  default     = true
}

variable "usage_metrics_enabled" {
  type        = bool
  description = "If set to `true`, all Object Storage bucket usage metrics are sent to Cloud Monitoring."
  default     = true
}

variable "monitoring_crn" {
  type        = string
  description = "The CRN of an IBM Cloud Monitoring instance to send Object Storage bucket metrics to. If no value is set, metrics are sent to the instance associated with the container's location unless otherwise specified in the Metrics Router service configuration."
  default     = null
}

variable "activity_tracker_read_data_events" {
  type        = bool
  description = "If set to `true`, all Object Storage bucket read events (i.e. downloads) are sent to Activity Tracker Event Routing."
  default     = true
}

variable "activity_tracker_write_data_events" {
  type        = bool
  description = "If set to `true`, all Object Storage bucket write events (i.e. uploads) are sent to Activity Tracker Event Routing."
  default     = true
}

variable "activity_tracker_management_events" {
  type        = bool
  description = "If set to `true`, all Object Storage management events are sent to Activity Tracker Event Routing."
  default     = true
}

variable "force_delete" {
  type        = bool
  description = "Whether to delete all the objects in the Object Storage bucket before the bucket is deleted."
  default     = true
}

variable "single_site_location" {
  type        = string
  description = "The single site bucket location. If specified, set the value of `region` and `cross_region_location` to `null`."
  default     = null

  validation {
    condition     = var.single_site_location == null || can(regex("ams03|mil01|mon01|par01|sjc04|sng01|che01", var.single_site_location))
    error_message = "Variable 'single_site_location' must be 'ams03', 'mil01', 'mon01', 'par01', 'sjc04', 'sng01', 'che01', or 'null'."
  }
}

variable "hard_quota" {
  type        = number
  description = "The maximum amount of available storage in bytes for a bucket. If set to `null`, the quota is disabled."
  default     = null
}

variable "expire_filter_prefix" {
  type        = string
  description = "Apply expire lifecycle rule to only objects with the following prefix. Applies to all objects by default."
  default     = null
}

variable "archive_filter_prefix" {
  type        = string
  description = "Apply archive lifecycle rule to only objects with the following prefix. Applies to all objects by default."
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "The number of days after which non-current versions will be deleted. If null is passed, no lifecycle configuration will be added for bucket non-current version expiration."
  type        = number
  default     = null
  validation {
    condition     = var.noncurrent_version_expiration_days == null || var.object_versioning_enabled == true
    error_message = "Noncurrent version expiration lifecycle rule requires object versioning. Make sure `object_versioning_enabled` is set to `true`."
  }
}

variable "noncurrent_version_expiration_filter_prefix" {
  type        = string
  description = "Apply noncurrent version expiration lifecycle rule to only objects with the following prefix. Applies to all objects by default."
  default     = null
  validation {
    condition     = var.noncurrent_version_expiration_filter_prefix == null || var.object_versioning_enabled == true
    error_message = "Noncurrent version expiration lifecycle filter prefix requires object versioning. Make sure `object_versioning_enabled` is set to `true`."
  }
}

variable "abort_multipart_days" {
  type        = number
  description = "The number of days after which incomplete multipart uploads will be aborted. If null is passed, no lifecycle configuration will be added for aborting multipart uploads."
  default     = null
}

variable "abort_multipart_filter_prefix" {
  type        = string
  description = "Apply abort incomplete multipart upload rule to only objects with the following prefix. Defaults to apply to all objects."
  default     = null
}

##############################################################################
# COS bucket encryption variables
##############################################################################

variable "existing_kms_instance_guid" {
  description = "The GUID of the Key Protect or Hyper Protect Crypto Services instance that holds the key specified in `kms_key_crn`. Required if `skip_iam_authorization_policy` is set to `false`."
  type        = string
  default     = null
  validation {
    condition     = var.kms_encryption_enabled == false || var.create_cos_bucket == false || var.skip_iam_authorization_policy == true || var.existing_kms_instance_guid != null
    error_message = "A value must be passed for `var.existing_kms_instance_guid` when a bucket is created if `var.kms_encryption_enabled` is set to `true` and `var.skip_iam_authorization_policy` is set to `false`."
  }
}

variable "kms_encryption_enabled" {
  description = "Whether to use key management service key encryption to encrypt data in Object Storage buckets. Applies only if `create_cos_bucket` is set to `true`."
  type        = bool
  default     = true
  validation {
    condition     = var.single_site_location == null || var.kms_encryption_enabled == false
    error_message = "If `var.single_site_location` is set, then `var.kms_encryption_enabled` cannot be set as Key Protect does not support single site location."
  }
}

variable "kms_key_crn" {
  description = "The CRN of the key management service key to encrypt the data in the Object Storage bucket. Required if `kms_encryption_enabled` and `create_cos_bucket` are set to `true`."
  type        = string
  default     = null

  validation {
    condition     = !(var.create_cos_bucket && var.kms_encryption_enabled && var.kms_key_crn == null)
    error_message = "A value must be passed for `var.kms_key_crn` when both `var.create_cos_bucket` and `var.kms_encryption_enabled` are set to `true`."
  }

  validation {
    condition     = var.cross_region_location == "us" || var.cross_region_location == null || !can(regex(".*hs-crypto.*", var.kms_key_crn))
    error_message = "Support for using a Hyper Protect Crypto Services instance for key encryption in a cross-regional bucket is only available in the US region."
  }
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
  description = "The list of context-based restriction rules to create for the bucket."
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
  description = "The list of context-based restriction rules to create for the instance."
  default     = []
  # Validation happens in the rule module
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the key management service instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy. If set to `false`, specify a value for the key management service instance in `existing_kms_guid`."
  default     = false
}
