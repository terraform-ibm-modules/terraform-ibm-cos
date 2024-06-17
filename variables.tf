##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID for the new Object Storage instance. Required only if `create_cos_instance` is true."
  default     = null
}

##############################################################################
# COS instance variables
##############################################################################

variable "create_cos_instance" {
  description = "Whether to create a IBM Cloud Object Storage instance."
  type        = bool
  default     = true
}

# 'name' is the terraform static reference to the object in the list
# 'key_name' is the IBM Cloud resource key name
# name MUST not be dynamic, so that it is known at plan time
# if key_name is not specified, name will be used for the key_name
# key_name can be a dynamic reference created during apply
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
    # Service roles (for Cloud Object Storage) https://cloud.ibm.com/iam/roles
    # Reader, Writer, Manager, Content Reader, Object Reader, Object Writer, NONE
    condition = alltrue([
      for key in var.resource_keys : contains(["Writer", "Reader", "Manager", "Content Reader", "Object Reader", "Object Writer", "NONE"], key.role)
    ])
    error_message = "resource_keys role must be one of 'Writer', 'Reader', 'Manager', 'Content Reader', 'Onject Reader', 'Object Writer', 'NONE', reference https://cloud.ibm.com/iam/roles and `Cloud Object Storage`"
  }
}

variable "cos_instance_name" {
  description = "The name for the IBM Cloud Object Storage instance provisioned by this module. Applies only if `create_cos_instance` is true."
  type        = string
  default     = null
}

variable "cos_location" {
  description = "The location for the Object Storage instance. Applies only if `create_cos_instance` is true."
  type        = string
  default     = "global"
}

variable "cos_plan" {
  description = "The plan to use when Object Storage instances are created. Possible values: `standard`, `lite`, `cos-one-rate-plan`. Applies only if `create_cos_instance` is true."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "lite", "cos-one-rate-plan"], var.cos_plan)
    error_message = "The specified cos_plan is not a valid selection!"
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
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

variable "existing_cos_instance_id" {
  description = "The ID of an existing cloud object storage instance. Required if `create_cos_instance` is false."
  type        = string
  default     = null
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
}

variable "cross_region_location" {
  description = "Specify the cross-region bucket location. Possible values: `us`, `eu` `ap`. If specified, set `region` and `single_site_location` to `null`."
  type        = string
  default     = null

  validation {
    condition     = var.cross_region_location == null || can(regex("us|eu|ap", var.cross_region_location))
    error_message = "Variable 'cross_region_location' must be 'us' or 'eu', 'ap', or 'null'."
  }
}

variable "bucket_name" {
  type        = string
  description = "The name for the new Object Storage bucket. Applies only if `create_cos_bucket` is true."
  default     = null
}

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Whether to add a randomly generated 4-character suffix to the new bucket name."
  default     = false
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the new bucket. Required only if `create_cos_bucket` is true. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`."
  default     = "standard"

  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$|^onerate_active", var.bucket_storage_class))
    error_message = "Variable 'bucket_storage_class' must be 'standard', 'vault', 'cold', 'smart' or 'onerate_active'."
  }
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to manage the bucket. Possible values: `public`, `private`, `direct`."
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The specified management_endpoint_type_for_bucket is not a valid selection!"
  }
}

# Where is retention (immuatble object storage) supported
# https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability#service-availability
variable "retention_enabled" {
  description = "Whether retention for the Object Storage bucket is enabled. Applies only if `create_cos_bucket` is true."
  type        = bool
  default     = false
}

variable "retention_default" {
  description = "The number of days that an object can remain unmodified in an Object Storage bucket. Applies only if `create_cos_bucket` is true."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_default == null ? true : (var.retention_default > 0 && var.retention_default < 365243)
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_maximum" {
  description = "The maximum number of days that an object can be kept unmodified in the bucket. Applies only if `create_cos_bucket` is true."
  type        = number
  default     = 350
  validation {
    condition     = (var.retention_maximum == null ? true : (var.retention_maximum > 0 && var.retention_maximum < 365243))
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_minimum" {
  description = "The minimum number of days that an object must be kept unmodified in the bucket. Applies only if `create_cos_bucket` is true."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_minimum == null ? true : (var.retention_minimum > 0 && var.retention_minimum < 365243)
    error_message = "The specified duration for retention minimum period is not a valid selection!"
  }
}

variable "retention_permanent" {
  description = "Whether permanent retention status is enabled for the Object Storage bucket. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-immutable). Applies only if `create_cos_bucket` is true."
  type        = bool
  default     = false
}

variable "object_locking_enabled" {
  description = "Whether to create an object lock configuration. Applies only if `object_versioning_enabled` and `create_cos_bucket` are true."
  type        = bool
  default     = false
}

variable "object_lock_duration_days" {
  description = "The number of days for the object lock duration. If you specify a number of days, do not specify a value for `object_lock_duration_years`. Applies only if `create_cos_bucket` is true."
  type        = number
  default     = 0
}

variable "object_lock_duration_years" {
  description = "The number of years for the object lock duration. If you specify a number of years, do not specify a value for `object_lock_duration_days`. Applies only if `create_cos_bucket` is true."
  type        = number
  default     = 0
}

variable "object_versioning_enabled" {
  description = "Whether to enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. Applies only if `create_cos_bucket` is true."
  type        = bool
  default     = false
}

variable "archive_days" {
  description = "The number of days before the `archive_type` rule action takes effect. Applies only if `create_cos_bucket` is true. Set to `null` if you specify a bucket location in `cross_region_location` because archive data is not supported with cross-region buckets."
  type        = number
  default     = 90
}

variable "archive_type" {
  description = "The storage class or archive type to which you want the object to transition. Possible values: `Glacier`, `Accelerated`. Applies only if `create_cos_bucket` is true."
  type        = string
  default     = "Glacier"
  validation {
    condition     = contains(["Glacier", "Accelerated"], var.archive_type)
    error_message = "The specified archive_type is not a valid selection!"
  }
}

variable "expire_days" {
  description = "The number of days before the expire rule action takes effect. Applies only if `create_cos_bucket` is true."
  type        = number
  default     = 365
}

variable "activity_tracker_crn" {
  type        = string
  description = "Activity tracker crn for the Object Storage bucket."
  default     = null
}

variable "sysdig_crn" {
  type        = string
  description = "Sysdig Monitoring crn for the Object Storage bucket."
  default     = null
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
    error_message = "Variable 'cross_region_location' must be 'ams03', 'mil01', 'mon01', 'par01', 'sjc04', 'sng01', 'che01' or 'null'."
  }
}

variable "hard_quota" {
  type        = number
  description = "The maximum amount of available storage in bytes for a bucket. If set to `null`, the quota is disabled."
  default     = null
}

##############################################################################
# COS bucket encryption variables
##############################################################################

variable "existing_kms_instance_guid" {
  description = "The GUID of the Key Protect or Hyper Protect Crypto Services instance that holds the key specified in `kms_key_crn`. Required if `skip_iam_authorization_policy` is false."
  type        = string
  default     = null
}

variable "kms_encryption_enabled" {
  description = "Whether to use KMS key encryption to encrypt data in Object Storage buckets. Applies only if `create_cos_bucket` is true."
  type        = bool
  default     = true
}

variable "kms_key_crn" {
  description = "The CRN of the KMS key to encrypt the data in the Object Storage bucket. Required if `kms_encryption_enabled` and `create_cos_bucket` are true."
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
  description = "Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy. If set to `false`, specify a value for the KMS instance in `existing_kms_guid`."
  default     = false
}
