variable "name" {
  description = "The name to give the Backup Vault instance."
  type        = string
}

variable "add_name_suffix" {
  type        = bool
  description = "Whether to add a randomly generated 4-character suffix to the Backup Vault name."
  default     = true
}

variable "existing_cos_instance_id" {
  description = "The ID of the Object Storage instance to create the Backup Vault instance in."
  type        = string
}

variable "region" {
  description = "The region to create the Backup Vault instance in."
  type        = string
  default     = "us-south"
}

variable "activity_tracking_management_events" {
  description = "Whether to enable activity tracking management events for the Backup Vault instance."
  type        = bool
  default     = true
}

variable "metrics_monitoring_usage_metrics" {
  description = "Whether to enable usage metrics monitoring for the Backup Vault instance."
  type        = bool
  default     = true
}

variable "kms_encryption_enabled" {
  description = "Whether to use key management service key encryption to encrypt data in the Backup Vault instance."
  type        = bool
  default     = false
}

variable "kms_key_crn" {
  description = "The CRN of the key management service root key to encrypt the data in the Backup Vault instance. Required if `kms_encryption_enabled` is set to `true`."
  type        = string
  default     = null

  validation {
    condition     = !(var.kms_encryption_enabled && var.kms_key_crn == null)
    error_message = "A value must be passed for `kms_key_crn` when `kms_encryption_enabled` is set to `true`."
  }
}

variable "skip_kms_iam_authorization_policy" {
  type        = bool
  description = "Set to true the skip the creation of an IAM authorization policy that grants the Object Storage instance 'Reader' access to the specified KMS key. This policies must exist in your account for encryption to work. Ignored if 'kms_encryption_enabled' is false."
  default     = false
}
