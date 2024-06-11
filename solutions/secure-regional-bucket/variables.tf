variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy IAM-enabled resources."
  sensitive   = true
}

########################################################################################################################
# KMS variables
########################################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the KMS instance that is used for the Object Storage bucket root key. Required only if a KMS root key is specified and if `skip_iam_authorization_policy` is true."
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits the Object Storage instance created to read the encryption key from the KMS instance in `existing_kms_guid`. WARNING: An authorization policy must exist before an encrypted bucket can be created"
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

variable "key_ring_name" {
  type        = string
  default     = "cross-region-key-ring"
  description = "The name to give the Key Ring which will be created for the Object Storage bucket Key. Not used if supplying an existing Key."
}

variable "key_name" {
  type        = string
  default     = "cross-region-key"
  description = "The name to give the Key which will be created for the Object Storage bucket. Not used if supplying an existing Key."
}

########################################################################################################################
# Object Storage variables
########################################################################################################################

variable "region" {
  description = "The region to provision the IBM Cloud Object Storage regional bucket is provisioned."
  type        = string
  default     = "us-south"
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Add random generated suffix (4 characters long) to the newly provisioned Object Storage bucket name (Optional)."
  default     = false
}

variable "existing_cos_instance_id" {
  description = "The ID of an existing Cloud Object Storage instance."
  type        = string
}

variable "bucket_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Cloud Object Storage instance bucket."
  default     = []
}

variable "bucket_name" {
  type        = string
  description = "The name to give the newly provisioned Object Storage bucket. "
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to use to manage the bucket. (public, private or direct)"
  type        = string
  default     = "private"
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the newly provisioned Object Storage bucket.  Supported values are `standard`, `vault`, `cold`, `smart` and `onerate_active`."
  default     = "smart"
}

variable "force_delete" {
  type        = bool
  description = "Deletes all the objects in the Object Storage Bucket before bucket is deleted."
  default     = true
}

variable "hard_quota" {
  type        = number
  description = "Sets a maximum amount of storage (in bytes) available for a bucket. If it is set to `null` then quota is disabled."
  default     = null
}

variable "activity_tracker_crn" {
  type        = string
  description = "Activity tracker crn for Object Storage bucket (Optional)"
  default     = null
}

variable "archive_days" {
  description = "Specifies the number of days when the archive rule action takes effect. This must be set to null when when using var.cross_region_location as archive data is not supported with this feature."
  type        = number
  default     = null
}

variable "archive_type" {
  description = "Specifies the storage class or archive type to which you want the object to transition. "
  type        = string
  default     = "Glacier"
}

variable "expire_days" {
  description = "Specifies the number of days when the expire rule action takes effect. "
  type        = number
  default     = null
}

variable "monitoring_crn" {
  type        = string
  description = "IBM Cloud Monitoring crn for Object Storage bucket (Optional)"
  default     = null
}

variable "object_versioning_enabled" {
  description = "Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. "
  type        = bool
  default     = false
}

variable "retention_enabled" {
  description = "Retention enabled for Object Storage bucket. "
  type        = bool
  default     = false
}

variable "retention_default" {
  description = "Specifies default duration of time an object that can be kept unmodified for Object Storage bucket. "
  type        = number
  default     = 90
}

variable "retention_maximum" {
  description = "Specifies maximum duration of time an object that can be kept unmodified for Object Storage bucket. "
  type        = number
  default     = 350
}

variable "retention_minimum" {
  description = "Specifies minimum duration of time an object must be kept unmodified for Object Storage bucket. "
  type        = number
  default     = 90
}

variable "retention_permanent" {
  description = "Specifies a permanent retention status either enable or disable for Object Storage bucket. "
  type        = bool
  default     = false
}

variable "object_locking_enabled" {
  description = "Specifies if an object lock configuration should be created. Requires 'object_versioning_enabled' to be true. Only used if 'create_cos_bucket' is true."
  type        = bool
  default     = false
}

variable "object_lock_duration_days" {
  description = "Specifies the default number of days for the retention lock duration. When setting 'object_lock_duration_days' do not set 'object_lock_duration_years'. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 0
}

variable "object_lock_duration_years" {
  description = "Specifies the default number of years for the retention lock duration. When setting 'object_lock_duration_years' do not set 'object_lock_duration_days'. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 0
}
