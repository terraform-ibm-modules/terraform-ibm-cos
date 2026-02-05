variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to null or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

########################################################################################################################
# KMS variables
########################################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the KMS instance that is used for the Object Storage bucket root key. Required only if a KMS root key is not specified and if `skip_cos_kms_iam_auth_policy` is false."
  validation {
    condition     = !(var.existing_kms_key_crn == null && var.existing_kms_instance_crn == null)
    error_message = "A value must be passed for 'existing_kms_instance_crn' if no value is supplied for 'existing_kms_key_crn'."
  }
}

variable "skip_cos_kms_iam_auth_policy" {
  type        = bool
  description = "Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy. If set to `false`, specify a value for the KMS instance in `existing_kms_instance_crn`."
  default     = false
}

variable "existing_kms_key_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing KMS key to be used to encrypt the Object Storage bucket. If not supplied, a new key ring and key will be created in the provided KMS instance."
}

variable "cos_key_ring_name" {
  type        = string
  default     = "cross-region-key-ring"
  description = "The name to give the Key Ring which will be created for the Object Storage bucket Key. Not used if supplying an existing Key."
}

variable "cos_key_name" {
  type        = string
  default     = "cross-region-key"
  description = "The name to give the Key which will be created for the Object Storage bucket. Not used if supplying an existing Key."
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the `ibmcloud_api_key` variable is used. Specify this key if the instance `existing_kms_instance_crn` is in an account that's different from the Object Storage instance. Not used if the same account owns both instances."
  sensitive   = true
  default     = null
}

########################################################################################################################
# Object Storage variables
########################################################################################################################

variable "existing_cos_instance_crn" {
  description = "The CRN of an existing Cloud Object Storage instance."
  type        = string
}

variable "bucket_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Object Storage instance created by the module. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-object-tagging)."
  default     = []
}

variable "bucket_name" {
  type        = string
  description = "The name to give the newly provisioned Object Storage bucket."
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to manage the bucket. Possible values:  `private`, `direct`."
  type        = string
  default     = "direct"
  validation {
    condition     = contains(["private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The value of management_endpoint_type_for_bucket must be one of: `private`, `direct`."
  }
}

variable "cross_region_location" {
  description = "Specify the cross-region bucket location. Possible values: `us`, `eu`, `ap`."
  type        = string
  default     = "us"
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the newly provisioned Object Storage bucket. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`."
  default     = "smart"
}

variable "force_delete" {
  type        = bool
  description = "Deletes all the objects in the Object Storage Bucket before bucket is deleted."
  default     = true
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Add random generated suffix (4 characters long) to the newly provisioned Object Storage bucket name (Optional)."
  default     = true
}

variable "bucket_hard_quota" {
  type        = number
  description = "Sets a maximum amount of storage (in bytes) available for a bucket. If it is set to `null` then quota is disabled."
  default     = null
}

variable "expire_filter_prefix" {
  type        = string
  description = "Apply expire lifecycle rule to only objects with the following prefix. Defaults to apply to all objects."
  default     = null
}

variable "archive_filter_prefix" {
  type        = string
  description = "Apply archive lifecycle rule to only objects with the following prefix. Defaults to apply to all objects."
  default     = null
}

variable "expire_days" {
  description = "The number of days before the expire rule action takes effect. If null is passed, no lifecycle configuration will be added for bucket expiration."
  type        = number
  default     = null
}

variable "archive_days" {
  description = "The number of days before the `archive_type` rule action takes effect. If null is passed, no lifecycle configuration will be added for bucket archival."
  type        = number
  default     = null
}

variable "archive_type" {
  description = "The storage class or archive type you want the object to transition to."
  type        = string
  default     = "Glacier"
}

variable "noncurrent_version_expiration_days" {
  description = "The number of days after which non-current versions will be deleted. If null is passed, no lifecycle configuration will be added for bucket non-current version expiration."
  type        = number
  default     = null
}

variable "noncurrent_version_expiration_filter_prefix" {
  type        = string
  description = "Apply noncurrent version expiration lifecycle rule to only objects with the following prefix. Defaults to apply to all objects."
  default     = null
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

variable "monitoring_crn" {
  type        = string
  description = "The CRN of an IBM Cloud Monitoring instance to to send Object Storage bucket metrics to. If no value passed, metrics are sent to the instance associated to the container's location unless otherwise specified in the Metrics Router service configuration."
  default     = null
}

variable "enable_object_versioning" {
  description = "Whether object versioning is enabled so that multiple versions of an object are retained in a bucket. Cannot be used if `enable_retention` is true."
  type        = bool
  default     = false
}

variable "default_retention_days" {
  description = "The number of days that an object can remain unmodified in an Object Storage bucket."
  type        = number
  default     = null
}

variable "maximum_retention_days" {
  description = "The maximum number of days that an object can be kept unmodified in the bucket."
  type        = number
  default     = null
}

variable "minimum_retention_days" {
  description = "The minimum number of days that an object must be kept unmodified in the bucket."
  type        = number
  default     = null
}

variable "enable_permanent_retention" {
  description = "Whether permanent retention status is enabled for the Object Storage bucket. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-immutable)."
  type        = bool
  default     = null
}

variable "enable_object_locking" {
  description = "Whether to create an object lock configuration. Applies only if `object_versioning_enabled` is true."
  type        = bool
  default     = false
}

variable "object_lock_duration_days" {
  description = "The number of days for the object lock duration. If you specify a number of days, do not specify a value for `object_lock_duration_years`."
  type        = number
  default     = 0
}

variable "object_lock_duration_years" {
  description = "The number of years for the object lock duration. If you specify a number of years, do not specify a value for `object_lock_duration_days`."
  type        = number
  default     = 0
}

##############################################################
# Context-based restriction (CBR)
##############################################################
variable "cos_bucket_cbr_rules" {
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
  description = "The list of context-based restriction rules to create for the instance.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/blob/main/solutions/cross-regional-bucket/security-enforced/DA-cbr_rules.md)."
  default     = []
  # Validation happens in the rule module
}
