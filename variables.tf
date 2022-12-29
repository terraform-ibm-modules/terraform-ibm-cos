##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

variable "region" {
  description = "Region to provision COS bucket. Also used when creating Key Protect / Key Protect Keys for encryption. NOTE: If 'var.encryption_enabled' is true and an existing Key Protect instance is passed in using 'var.existing_key_protect_instance_guid', this must be the region of the existing Key Protect instance."
  type        = string
  default     = "us-south"
}

##############################################################################
# COS instance variables
##############################################################################

variable "create_cos_instance" {
  description = "Set as true to create a new Cloud Object Storage instance."
  type        = bool
  default     = true
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
    condition     = contains(["standard", "lite"], var.cos_plan)
    error_message = "The specified cos_plan is not a valid selection!"
  }
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

##############################################################################
# COS bucket variables
##############################################################################

variable "create_cos_bucket" {
  description = "Set as true to create a new Cloud Object Storage bucket"
  type        = bool
  default     = true
}

variable "bucket_name" {
  type        = string
  description = "The name to give the newly provisioned COS bucket. Only required if 'create_cos_bucket' is true."
  default     = null
}

variable "retention_enabled" {
  description = "Retention enabled for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = bool
  default     = true
}

variable "retention_default" {
  description = "Specifies default duration of time an object that can be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_default > 0 && var.retention_default < 365243
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_maximum" {
  description = "Specifies maximum duration of time an object that can be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 350
  validation {
    condition     = var.retention_maximum > 0 && var.retention_maximum < 365243
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_minimum" {
  description = "Specifies minimum duration of time an object must be kept unmodified for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_minimum > 0 && var.retention_minimum < 365243
    error_message = "The specified duration for retention minimum period is not a valid selection!"
  }
}

variable "retention_permanent" {
  description = "Specifies a permanent retention status either enable or disable for COS bucket. Only used if 'create_cos_bucket' is true."
  type        = bool
  default     = false
}

variable "object_versioning_enabled" {
  description = "Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. Only used if 'create_cos_bucket' is true."
  type        = bool
  default     = false
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

##############################################################################
# COS encryption variables
##############################################################################

variable "encryption_enabled" {
  description = "Set as true to use Key Protect encryption to encrypt data in COS bucket"
  type        = bool
  default     = true
}

variable "create_key_protect_instance" {
  description = "Set as true to create a new Key Protect instance. This instance will store the Key used to encrypt the data in the COS Bucket"
  type        = bool
  default     = true
}

variable "key_protect_instance_name" {
  description = "The name to give the Key Protect instance that will be provisioned by this module. Required if 'var.create_key_protect_instance' is true"
  type        = string
  default     = null
}

variable "enable_key_protect_metrics" {
  description = "Enable Key Protect metrics. Only used if if 'var.create_key_protect_instance' is true."
  type        = string
  default     = true
}

variable "existing_key_protect_instance_guid" {
  description = "The GUID of an existing Key Protect instance. Required if 'var.create_key_protect_instance' is false."
  type        = string
  default     = null
}

variable "key_protect_tags" {
  description = "Optional list of tags to be added to Key Protect instance. Only used if 'var.create_key_protect_instance' is true."
  type        = list(string)
  default     = []
}

variable "create_key_protect_key" {
  description = "Set as true to create a new Key Protect Key. This key is used to encrypt the COS Bucket"
  type        = bool
  default     = true
}

variable "cos_key_ring_name" {
  description = "The name of a new Key Ring to create in the Key Protect instance. The Key name specified in var.cos_key_name will be created in this Key Ring."
  type        = string
  default     = "cos-key-ring"
}

variable "existing_cos_key_ring_name" {
  description = "The name of an existing Key Ring in which to create the new Key specified in var.cos_key_name"
  type        = string
  default     = null
}

variable "cos_key_name" {
  description = "The name of the Key Protect Key to create. This key will be used to encrypt the data in the COS Bucket, and will be created in the specified Key Ring passed to this module using either var.cos_key_ring_name or var.existing_cos_key_ring_name."
  type        = string
  default     = "cos-key"
}

variable "key_protect_key_crn" {
  description = "CRN of the Key Protect Key to use if not creating a Key in this module, this Key Protect Key is used to encrypt the data in the COS Bucket"
  type        = string
  default     = null
}
