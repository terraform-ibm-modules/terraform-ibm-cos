variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

########################################################################################################################
# KMS variables
########################################################################################################################

variable "kms_region" {
  type        = string
  default     = "us-south"
  description = "The region in which KMS instance exists."
}

variable "existing_kms_guid" {
  type        = string
  default     = null
  description = "The GUID of the KMS instance used for the COS bucket root Key. Only required if not supplying an existing KMS root key and if 'skip_iam_authorization_policy' is true."
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits the COS instance created to read the encryption key from the KMS instance in `existing_kms_guid`. WARNING: An authorization policy must exist before an encrypted bucket can be created"
  default     = false
}

variable "existing_kms_key_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing KMS key to be used to encrypt the COS bucket. If not supplied, a new key ring and key will be created in the provided KMS instance."
}

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to be used for communicating with the KMS instance. Allowed values are: 'public' or 'private' (default)"
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "The kms_endpoint_type value must be 'public' or 'private'."
  }
}

variable "key_ring_name" {
  type        = string
  default     = "cross-region-key-ring"
  description = "The name to give the Key Ring which will be created for the COS bucket Key. Not used if supplying an existing Key."
}

variable "key_name" {
  type        = string
  default     = "cross-region-key"
  description = "The name to give the Key which will be created for the COS bucket. Not used if supplying an existing Key."
}

########################################################################################################################
# COS variables
########################################################################################################################

variable "region" {
  description = "The region to provision the IBM Cloud Object Storage regional bucket is provisioned."
  type        = string
  default     = "us-south"
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Add random generated suffix (4 characters long) to the newly provisioned COS bucket name (Optional)."
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
  description = "The name to give the newly provisioned COS bucket. "
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to use to manage the bucket. (public, private or direct)"
  type        = string
  default     = "private"
}

variable "bucket_storage_class" {
  type        = string
  description = "the storage class of the newly provisioned COS bucket.  Supported values are 'standard', 'vault', 'cold', 'smart' and `onerate_active`."
  default     = "smart"
}

variable "force_delete" {
  type        = bool
  description = "Deletes all the objects in the COS Bucket before bucket is deleted."
  default     = true
}

variable "hard_quota" {
  type        = number
  description = "Sets a maximum amount of storage (in bytes) available for a bucket. If it is set to `null` then quota is disabled."
  default     = null
}

variable "activity_tracker_crn" {
  type        = string
  description = "Activity tracker crn for COS bucket (Optional)"
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
  description = "IBM Cloud Monitoring crn for COS bucket (Optional)"
  default     = null
}

variable "object_versioning_enabled" {
  description = "Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. "
  type        = bool
  default     = false
}

variable "retention_enabled" {
  description = "Retention enabled for COS bucket. "
  type        = bool
  default     = false
}

variable "retention_default" {
  description = "Specifies default duration of time an object that can be kept unmodified for COS bucket. "
  type        = number
  default     = 90
}

variable "retention_maximum" {
  description = "Specifies maximum duration of time an object that can be kept unmodified for COS bucket. "
  type        = number
  default     = 350
}

variable "retention_minimum" {
  description = "Specifies minimum duration of time an object must be kept unmodified for COS bucket. "
  type        = number
  default     = 90
}

variable "retention_permanent" {
  description = "Specifies a permanent retention status either enable or disable for COS bucket. "
  type        = bool
  default     = false
}
