##############################################################################
# Input Variables
##############################################################################

# Resource Group Variables
variable "resource_group_id" {
  type        = string
  description = "The resource group ID where the environment will be created"
}

variable "environment_name" {
  description = "Prefix name for all related resources"
  type        = string
}

variable "bucket_infix" {
  type        = string
  description = "Custom infix for use in cos bucket name (Optional)"
  default     = null
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

variable "region" {
  description = "Name of the Region to deploy in to"
  type        = string
  default     = "us-south"
}

variable "key_protect_instance_name" {
  description = "Name of an existing Key Protect instance to use, this instance will store the Key used to encrypt the data in the COS Bucket"
  type        = string
  default     = null
}

variable "create_cos_instance" {
  description = "Set as true to create a new Cloud Object Storage instance"
  type        = bool
  default     = true
}

variable "cos_instance_name" {
  description = "Name of the cos instance where the bucket should be created"
  type        = string
  default     = null
}

variable "key_protect_key_crn" {
  description = "CRN of the Key Protect Key to use, this Key Protect Key is used to encrypt the data in the COS Bucket"
  type        = string
  default     = null
}

variable "encryption_enabled" {
  description = "Set as true to use Key Protect encryption to encrypt data in COS bucket"
  type        = bool
  default     = true
}

variable "archive_days" {
  description = "Specifies the number of days when the archive rule action takes effect."
  type        = number
  default     = 90
}

variable "archive_type" {
  description = "Specifies the storage class or archive type to which you want the object to transition."
  type        = string
  default     = "Glacier"
  validation {
    condition     = contains(["Glacier", "Accelerated"], var.archive_type)
    error_message = "The specified archive_type is not a valid selection!"
  }
}

variable "expire_days" {
  description = "Specifies the number of days when the expire rule action takes effect."
  type        = number
  default     = 365
}

# COS instance configuration
variable "cos_plan" {
  description = "Plan to be used for creating cloud object storage instance"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "lite"], var.cos_plan)
    error_message = "The specified cos_plan is not a valid selection!"
  }
}

variable "cos_location" {
  description = "Location of the cloud object storage instance"
  type        = string
  default     = "global"
}

variable "retention_enabled" {
  description = "Retention enabled for COS bucket"
  type        = bool
  default     = true
}

variable "retention_default" {
  description = "Specifies default duration of time an object that can be kept unmodified for COS bucket"
  type        = number
  default     = 90
  validation {
    condition     = var.retention_default > 0 && var.retention_default < 365243
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_maximum" {
  description = "Specifies maximum duration of time an object that can be kept unmodified for COS bucket"
  type        = number
  default     = 350
  validation {
    condition     = var.retention_maximum > 0 && var.retention_maximum < 365243
    error_message = "The specified duration for retention maximum period is not a valid selection!"
  }
}

variable "retention_minimum" {
  description = "Specifies minimum duration of time an object must be kept unmodified for COS bucket"
  type        = number
  default     = 90
  validation {
    condition     = var.retention_minimum > 0 && var.retention_minimum < 365243
    error_message = "The specified duration for retention minimum period is not a valid selection!"
  }
}

variable "retention_permanent" {
  description = "Specifies a permanent retention status either enable or disable for COS bucket"
  type        = bool
  default     = false
}

variable "object_versioning_enabled" {
  description = "Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule."
  type        = bool
  default     = false
}
