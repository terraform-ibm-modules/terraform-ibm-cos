##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where The COS instance will be provisioned. It is required if setting input variable create_cos_instance to true."
  default     = null
}

##############################################################################
# COS instance variables
##############################################################################

variable "create_cos_instance" {
  description = "Set as true to create a new Cloud Object Storage instance."
  type        = bool
  default     = true
}

# 'name' is the terraform static reference to the object in the list
# 'key_name' is the IBM Cloud resource key name
# name MUST not be dynamic, so that it is known at plan time
# if key_name is not specified, name will be used for the key_name
# key_name can be a dynamic reference created during apply
variable "resource_keys" {
  description = "The definition of any resource keys to be generated"
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
    # Reader, Writer, Manager, Content Reader, Object Reader, Object Writer, None
    condition = alltrue([
      for key in var.resource_keys : contains(["Writer", "Reader", "Manager", "Content Reader", "Object Reader", "Object Writer", "None"], key.role)
    ])
    error_message = "resource_keys role must be one of 'Writer', 'Reader', 'Manager', 'Content Reader', 'Onject Reader', 'Object Writer', 'None', reference https://cloud.ibm.com/iam/roles and `Cloud Object Storage`"
  }
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
    condition     = contains(["standard", "lite", "cos-one-rate-plan"], var.cos_plan)
    error_message = "The specified cos_plan is not a valid selection!"
  }
}

variable "cos_tags" {
  description = "Optional list of tags to be added to cloud object storage instance. Only used if 'create_cos_instance' it true."
  type        = list(string)
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the cos instance created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details"
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

variable "existing_cos_instance_id" {
  description = "The ID of an existing cloud object storage instance. Required if 'var.create_cos_instance' is false."
  type        = string
  default     = null
}

##############################################################################
# COS bucket variables
##############################################################################

variable "region" {
  description = "The region to provision the bucket. If you pass a value for this, do not pass one for var.cross_region_location or var.single_site_location."
  type        = string
  default     = "us-south"
}

variable "create_cos_bucket" {
  description = "Set as true to create a new Cloud Object Storage bucket"
  type        = bool
  default     = true
}

variable "cross_region_location" {
  description = "Specify the cross-regional bucket location. Supported values are 'us', 'eu', and 'ap'. If you pass a value for this, ensure to set the value of var.region and var.single_site_location to null."
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

variable "add_bucket_name_suffix" {
  type        = bool
  description = "Add random generated suffix (4 characters long) to the newly provisioned COS bucket name (Optional)."
  default     = false
}

variable "bucket_storage_class" {
  type        = string
  description = "the storage class of the newly provisioned COS bucket. Only required if 'create_cos_bucket' is true. Supported values are 'standard', 'vault', 'cold', 'smart' and `onerate_active`."
  default     = "standard"

  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$|^onerate_active", var.bucket_storage_class))
    error_message = "Variable 'bucket_storage_class' must be 'standard', 'vault', 'cold', 'smart' or 'onerate_active'."
  }
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to use to manage the bucket. (public, private or direct)"
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
  description = "Retention enabled for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = bool
  default     = false
}

variable "retention_default" {
  description = "Specifies default duration of time an object that can be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_default == null ? true : (var.retention_default > 0 && var.retention_default < 365243)
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_maximum" {
  description = "Specifies maximum duration of time an object that can be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 350
  validation {
    condition     = (var.retention_maximum == null ? true : (var.retention_maximum > 0 && var.retention_maximum < 365243))
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_minimum" {
  description = "Specifies minimum duration of time an object must be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_minimum == null ? true : (var.retention_minimum > 0 && var.retention_minimum < 365243)
    error_message = "The specified duration for retention minimum period is not a valid selection!"
  }
}

variable "retention_permanent" {
  description = "Specifies a permanent retention status either enable or disable for COS bucket. Only used if 'create_cos_bucket' is true."
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

variable "force_delete" {
  type        = bool
  description = "Deletes all the objects in the COS Bucket before bucket is deleted."
  default     = true
}

variable "single_site_location" {
  type        = string
  description = "Specify the single site bucket location. If you pass a value for this, ensure to set the value of var.region and var.cross_region_location to null."
  default     = null

  validation {
    condition     = var.single_site_location == null || can(regex("ams03|mil01|mon01|par01|sjc04|sng01|che01", var.single_site_location))
    error_message = "Variable 'cross_region_location' must be 'ams03', 'mil01', 'mon01', 'par01', 'sjc04', 'sng01', 'che01' or 'null'."
  }
}

variable "hard_quota" {
  type        = number
  description = "Sets a maximum amount of storage (in bytes) available for a bucket. If it is set to `null` then quota is disabled."
  default     = null
}

##############################################################################
# COS bucket encryption variables
##############################################################################

variable "existing_kms_instance_guid" {
  description = "The GUID of the Key Protect or Hyper Protect instance in which the key specified in var.kms_key_crn is coming from. Required if var.skip_iam_authorization_policy is false in order to create an IAM Access Policy to allow Key Protect or Hyper Protect to access the newly created COS instance."
  type        = string
  default     = null
}

variable "kms_encryption_enabled" {
  description = "Set as true to use KMS key encryption to encrypt data in COS bucket (only applicable when var.create_cos_bucket is true)."
  type        = bool
  default     = true
}

variable "kms_key_crn" {
  description = "CRN of the KMS key to use to encrypt the data in the COS bucket. Required if var.encryption_enabled and var.create_cos_bucket are true."
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

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits the COS instance created to read the encryption key from the KMS instance in `existing_kms_instance_guid`. WARNING: An authorization policy must exist before an encrypted bucket can be created"
  default     = false
}
