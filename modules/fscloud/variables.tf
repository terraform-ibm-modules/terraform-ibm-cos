##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

##############################################################################
# COS instance variables
##############################################################################

variable "create_cos_instance" {
  description = "Set as true to create a new Cloud Object Storage instance."
  type        = bool
  default     = true
}

variable "create_hmac_key" {
  description = "Set as true to create a new HMAC key for the Cloud Object Storage instance."
  type        = bool
  default     = false
}

variable "hmac_key_name" {
  description = "The name of the hmac key to be created."
  type        = string
  default     = "hmac-cos-key"
}

variable "hmac_key_role" {
  description = "The role you want to be associated with your new hmac key. Valid roles are 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer'."
  type        = string
  default     = "Manager"
}

variable "cos_instance_name" {
  description = "The name to give the cloud object storage instance that will be provisioned by this module. Only required if 'create_cos_instance' is true."
  type        = string
  default     = null
}

variable "cos_tags" {
  description = "Optional list of tags to be added to cloud object storage instance. Only used if 'create_cos_instance' it true."
  type        = list(string)
  default     = []
}

variable "existing_cos_instance_id" {
  description = "The ID of an existing cloud object storage instance. Required if 'var.create_cos_instance' is false."
  type        = string
  default     = null
}

variable "cos_plan" {
  description = "Plan to be used for creating cloud object storage instance. Only used if 'create_cos_instance' it true."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard"], var.cos_plan)
    error_message = "The specified cos_plan is not a valid selection!"
  }
}

##############################################################################
# COS bucket variables
##############################################################################

variable "create_cos_bucket" {
  description = "Set as true to create a new Cloud Object Storage bucket"
  type        = bool
  default     = true
}

variable "primary_region" {
  description = "region for the primary bucket"
  type        = string
  default     = "us-south"
}

variable "secondary_region" {
  description = "region for the secondary bucket"
  type        = string
  default     = "us-east"
}

variable "primary_bucket_name" {
  type        = string
  description = "The name to give the newly provisioned COS bucket. Only required if 'create_cos_bucket' is true."
  default     = null
}

variable "secondary_bucket_name" {
  type        = string
  description = "The name to give the newly provisioned COS bucket. Only required if 'create_cos_bucket' is true."
  default     = null
}

variable "bucket_storage_class" {
  type        = string
  description = "the storage class of the newly provisioned COS bucket. Only required if 'create_cos_bucket' is true. Supported values are 'standard', 'vault', 'cold', and 'smart'."
  default     = "standard"

  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$", var.bucket_storage_class))
    error_message = "Variable 'bucket_storage_class' must be 'standard', 'vault', 'cold', or 'smart'."
  }
}

variable "activity_tracker_crn" {
  type        = string
  description = "Activity tracker crn for COS bucket. Only required if 'create_cos_bucket' is true."
  default     = null
}

variable "sysdig_crn" {
  type        = string
  description = "Sysdig Monitoring crn for COS bucket. Only required if 'create_cos_bucket' is true."
  default     = null
}

variable "archive_days" {
  description = "Specifies the number of days when the archive rule action takes effect. Only used if 'create_cos_bucket' is true."
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

##############################################################################
# COS bucket encryption variables
##############################################################################

variable "primary_existing_hpcs_instance_guid" {
  description = "The GUID of the Hyper Protect Crypto service in which the key specified in var.hpcs_key_crn is coming from. Required if var.create_cos_instance is true in order to create an IAM Access Policy to allow Key Protect to access the newly created COS instance. Only required if 'create_cos_bucket' is true."
  type        = string
  default     = null
}

variable "secondary_existing_hpcs_instance_guid" {
  description = "The GUID of the Hyper Protect Crypto service in which the key specified in var.hpcs_key_crn is coming from. Required if var.create_cos_instance is true in order to create an IAM Access Policy to allow Key Protect to access the newly created COS instance. Only required if 'create_cos_bucket' is true."
  type        = string
  default     = null
}

variable "primary_hpcs_key_crn" {
  description = "CRN of the Hyper Protect Crypto service to use to encrypt the data in the COS bucket. Only required if 'create_cos_bucket' is true."
  type        = string
  default     = null
}

variable "secondary_hpcs_key_crn" {
  description = "CRN of the Hyper Protect Crypto service to use to encrypt the data in the COS bucket. Only required if 'create_cos_bucket' is true."
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

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access tags to be added to the created resources"
  default     = []
}
