variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
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
  description = "Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy. If set to `false`, specify a value for the KMS instance in `existing_kms_guid`."
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
  description = "The name for the new key ring for the Object Storage bucket key. Does not apply if a key is specified in `existing_kms_key_crn`."
}

variable "key_name" {
  type        = string
  default     = "cross-region-key"
  description = "The name for the new key for the Object Storage bucket. Does not apply if a key is specified in `existing_kms_key_crn`."
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the `ibmcloud_api_key` variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the Object Storage instance. Not used if the same account owns both instances."
  sensitive   = true
  default     = null
}

########################################################################################################################
# Object Storage variables
########################################################################################################################

variable "region" {
  description = "The region to provision the Object Storage regional bucket."
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
  default     = "private"
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the newly provisioned Object Storage bucket. Possible values: `standard`, `vault`, `cold`, `smart` `onerate_active`."
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

variable "archive_days" {
  description = "The number of days before the `archive_type` rule action takes effect."
  type        = number
  default     = null
}

variable "archive_type" {
  description = "The storage class or archive type you want the object to transition to."
  type        = string
  default     = "GLACIER"
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

variable "object_versioning_enabled" {
  description = "Whether object versioning is enabled so that multiple versions of an object are retained in a bucket. Cannot be used if `retention_enabled` is true."
  type        = bool
  default     = false
}

variable "retention_enabled" {
  description = "Whether retention is enabled for the Object Storage bucket."
  type        = bool
  default     = false
}

variable "retention_default" {
  description = "The number of days that an object can remain unmodified in an Object Storage bucket."
  type        = number
  default     = 90
}

variable "retention_maximum" {
  description = "The maximum number of days that an object can be kept unmodified in the bucket."
  type        = number
  default     = 350
}

variable "retention_minimum" {
  description = "The minimum number of days that an object must be kept unmodified in the bucket."
  type        = number
  default     = 90
}

variable "retention_permanent" {
  description = "Whether permanent retention status is enabled for the Object Storage bucket. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-immutable)."
  type        = bool
  default     = false
}

variable "object_locking_enabled" {
  description = "Whether to create an object lock configuration. Applies only if `object_versioning_enabled` and `create_cos_bucket` are true."
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
