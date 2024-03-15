variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "region" {
  description = "The IBM Cloud region where the instance of IBM Cloud-Object-Storage is provisioned."
  type        = string
  default     = "us-south"
}

variable "create_cos_instance" {
  description = "Set as true to create a new IBM Cloud-Object-Storage instance."
  type        = bool
  default     = true
}

variable "existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which Cloud-Object-Storage instance will be provisioned."
}

variable "create_resource_key" {
  description = "Set as true to create a new resource key for the Cloud-Object-Storage instance."
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
  description = "The role you want to be associated with your new resource key. Valid roles are `Writer`, `Reader`, `Manager`, `Content Reader`, `Object Reader`, `Object Writer`."
  type        = string
  default     = "Manager"
}

variable "cos_instance_name" {
  description = "The name of the IBM Cloud-Object-Storage instance. Only required if `create_cos_instance` is true."
  type        = string
}

variable "cos_tags" {
  description = "Optional list of tags to be added to Cloud-Object-Storage instance. Only used if `create_cos_instance` it true."
  type        = list(string)
  default     = []
}

variable "existing_cos_instance_id" {
  description = "The ID of an existing Cloud-Object-Storage instance. Required if `var.create_cos_instance` is false."
  type        = string
  default     = null
}

variable "cos_plan" {
  description = "Plan to be used for creating Cloud-Object-Storage instance. Only used if `create_cos_instance` it true."
  type        = string
  default     = "standard"
  # Validation happens in the fscloud module
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Cloud-Object-Storage instance."
  default     = []
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
  description = "(Optional, list) List of CBR rule to create for the instance"
  default     = []
  # Validation happens in the CBR Rule module
}

variable "bucket_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Cloud-Object-Storage instance bucket."
  default     = []
}

variable "bucket_name" {
  type        = string
  description = "The name to give the newly provisioned COS bucket. Only required if `create_cos_bucket` is true."
  default     = "cross-region-bucket"
}

variable "kms_encryption_enabled" {
  description = "Set as true to use KMS key encryption to encrypt data in COS bucket (only applicable when var.create_cos_bucket is true)."
  type        = bool
  default     = true
}

variable "existing_kms_instance_guid" {
  description = "The GUID of the Key Protect or Hyper Protect instance in which the key specified in var.kms_key_crn is coming from. Required if var.skip_iam_authorization_policy is false in order to create an IAM Access Policy to allow Key Protect or Hyper Protect to access the newly created COS instance."
  type        = string
  default     = null
}

variable "kms_key_crn" {
  description = "CRN of the KMS key to use to encrypt the data in the COS bucket. Required if var.encryption_enabled and var.create_cos_bucket are true."
  type        = string
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits the COS instance created to read the encryption key from the KMS instance in `existing_kms_instance_guid`. WARNING: An authorization policy must exist before an encrypted bucket can be created"
  default     = false
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to use to manage the bucket. (public, private or direct)"
  type        = string
  default     = "private"
}

variable "cross_region_location" {
  description = "Specify the cross-regional bucket location. Supported values are `us`, `eu`, and `ap`. If you pass a value for this, ensure to set the value of var.region and var.single_site_location to null."
  type        = string
}

variable "bucket_storage_class" {
  type        = string
  description = "the storage class of the newly provisioned COS bucket. Only required if `create_cos_bucket` is true. Supported values are `standard`, `vault`, `cold`, `smart` and `onerate_active`."
  default     = "smart"
}

variable "force_delete" {
  type        = bool
  description = "Deletes all the objects in the COS Bucket before bucket is deleted."
  default     = true
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Add random generated suffix (4 characters long) to the newly provisioned COS bucket name (Optional)."
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

variable "expire_days" {
  description = "Specifies the number of days when the expire rule action takes effect. Only used if `create_cos_bucket` is true."
  type        = number
  default     = null
}

variable "sysdig_crn" {
  type        = string
  description = "Sysdig Monitoring crn for COS bucket (Optional)"
  default     = null
}

variable "object_versioning_enabled" {
  description = "Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. Only used if `create_cos_bucket` is true."
  type        = bool
  default     = false
}

variable "retention_enabled" {
  description = "Retention enabled for COS bucket. Supported only in `us` location. Only used if `create_cos_bucket` is true."
  type        = bool
  default     = false
}

variable "retention_default" {
  description = "Specifies default duration of time an object that can be kept unmodified for COS bucket. Only used if `create_cos_bucket` is true."
  type        = number
  default     = 90
}

variable "retention_maximum" {
  description = "Specifies maximum duration of time an object that can be kept unmodified for COS bucket. Only used if `create_cos_bucket` is true."
  type        = number
  default     = 350
}

variable "retention_minimum" {
  description = "Specifies minimum duration of time an object must be kept unmodified for COS bucket. Only used if `create_cos_bucket` is true."
  type        = number
  default     = 90
}

variable "retention_permanent" {
  description = "Specifies a permanent retention status either enable or disable for COS bucket. Only used if `create_cos_bucket` is true."
  type        = bool
  default     = false
}

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
