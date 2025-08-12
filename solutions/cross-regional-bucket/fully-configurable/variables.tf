variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-cos-buc. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

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

variable "kms_encryption_enabled" {
  type        = bool
  description = "Set to true to enable Object Storage bucket Encryption using customer managed keys. When set to true, a value must be passed for either `existing_kms_instance_crn` or `existing_kms_key_crn`."
  default     = false

  validation {
    condition     = var.existing_kms_instance_crn != null ? var.kms_encryption_enabled : true
    error_message = "If passing a value for 'existing_kms_instance_crn', you should set 'kms_encryption_enabled' to true."
  }

  validation {
    condition     = var.existing_kms_key_crn != null ? var.kms_encryption_enabled : true
    error_message = "If passing a value for 'existing_kms_key_crn', you should set 'kms_encryption_enabled' to true."
  }

  validation {
    condition     = var.kms_encryption_enabled ? ((var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null) ? true : false) : true
    error_message = "Either 'existing_kms_instance_crn' or `existing_kms_key_crn` is required if 'kms_encryption_enabled' is set to true."
  }
}

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the KMS instance that is used for the Object Storage bucket root key. Required only if a KMS root key is not specified and if `skip_cos_kms_iam_auth_policy` is false."
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

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to use to communicate with the KMS instance. Allowed values are `public` or `private` (default)."
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "The value for `kms_endpoint_type` must be `public` or `private`."
  }
}

variable "cos_key_ring_name" {
  type        = string
  default     = "cross-regional-bucket-key-ring"
  description = "The name to give the Key Ring which will be created for the Object Storage bucket Key. Not used if supplying an existing Key."
}

variable "cos_key_name" {
  type        = string
  default     = "cross-regional-bucket-key"
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
  description = "The type of endpoint for the IBM terraform provider to manage the bucket. Possible values: `public`, `private`, `direct`."
  type        = string
  default     = "direct"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The value of management_endpoint_type_for_bucket must be one of: `public`, `private`, `direct`."
  }
}

variable "cross_region_location" {
  description = "Specify the cross-region bucket location. Possible values: `us`, `eu`, `ap`."
  type        = string

  validation {
    condition     = contains(["us", "eu", "ap"], var.cross_region_location)
    error_message = "The value of cross_region_location must be one of: 'us', 'eu', or 'ap'."
  }
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the newly provisioned Object Storage bucket. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`."
  default     = "smart"

  validation {
    condition     = contains(["standard", "vault", "cold", "smart", "onerate_active"], var.bucket_storage_class)
    error_message = "The value of bucket_storage_class must be one of: 'standard', 'vault', 'cold', 'smart', or 'onerate_active'."
  }
}

variable "force_delete" {
  type        = bool
  description = "To delete all the objects in the Object Storage Bucket before bucket is deleted."
  default     = true
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Add random generated suffix (4 characters long) to the newly provisioned Object Storage bucket name (Optional)."
  default     = false
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
  description = "The number of days before the expire rule action takes effect."
  type        = number
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

variable "enable_retention" {
  description = "Whether retention is enabled for the Object Storage bucket."
  type        = bool
  default     = false
}

variable "default_retention_days" {
  description = "The number of days that an object can remain unmodified in an Object Storage bucket."
  type        = number
  default     = 90
}

variable "maximum_retention_days" {
  description = "The maximum number of days that an object can be kept unmodified in the bucket."
  type        = number
  default     = 350
}

variable "minimum_retention_days" {
  description = "The minimum number of days that an object must be kept unmodified in the bucket."
  type        = number
  default     = 90
}

variable "enable_permanent_retention" {
  description = "Whether permanent retention status is enabled for the Object Storage bucket. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-immutable)."
  type        = bool
  default     = false
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
variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "noncurrent_expire_days" {
  type        = number
  description = "Number of days after which noncurrent versions are deleted."
  default     = 30
}

variable "noncurrent_expire_filter_prefix" {
  type        = string
  description = "Prefix for noncurrent version expiration."
  default     = null
}

variable "abort_multipart_days" {
  type        = number
  description = "Number of days after initiation to abort incomplete multipart uploads."
  default     = 3
}

variable "abort_multipart_filter_prefix" {
  type        = string
  description = "Prefix for aborting incomplete multipart uploads."
  default     = null
}

########################################################################################################################
# Replication variables
########################################################################################################################

variable "enable_replication" {
  description = "Enable COS replication rule and create a destination bucket"
  type        = bool
  default     = false
}

variable "replication_destination_bucket_name" {
  type        = string
  description = "Name prefix for replication destination bucket."
  default     = "rep-dt"

  # validation {
  #   condition     = var.enable_replication && var.replication_destination_bucket_name == null ? false : true
  #   error_message = "When `enable_replication` is true, a value must be passed for `replication_destination_bucket_name` ."
  # }
}

variable "replication_bucket_region" {
  type        = string
  description = "The region in which the replication bucket is to be provisioned."
  default     = "eu-de"

  # validation {
  #   condition     = var.region == var.replication_bucket_region ? false : true
  #   error_message = "The source bucket and destination bucket should have different regions."
  # }
}

variable "replication_priority" {
  type        = number
  description = "Priority for replication rule."
  default     = 1
}

variable "replication_rule_id" {
  type        = string
  description = "Replication rule id."
  default     = "Rule-1"
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
  description = "The list of context-based restriction rules to create for the instance.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/blob/main/solutions/cross-regional-bucket/fully-configurable/DA-cbr_rules.md)."
  default     = []
  # Validation happens in the rule module
}
