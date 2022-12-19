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

variable "create_cos_instance" {
  description = "Set as true to create a new Cloud Object Storage instance"
  type        = bool
  default     = true
}

variable "create_cos_bucket" {
  description = "Set as true to create a new Cloud Object Storage bucket"
  type        = bool
  default     = true
}

variable "cos_instance_name" {
  description = "Name of the COS instance to create when create_cos_instance is true, the name of COS instance to create buckets in"
  type        = string
  default     = null
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

variable "cos_tags" {
  description = "Optional list of tags to be added to cloud object storage instance."
  type        = list(string)
  default     = []
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

variable "encryption_enabled" {
  description = "Set as true to use Key Protect encryption to encrypt data in COS bucket"
  type        = bool
  default     = true
}

variable "create_key_protect_instance" {
  description = "Set as true to create a new Key Protect instance, this instance will store the Key used to encrypt the data in the COS Bucket"
  type        = bool
  default     = true
}

variable "key_protect_instance_name" {
  description = "Name to set as the instance name if creating a Key Protect instance, otherwise name of an existing Key Protect instance to use, this instance will store the Key used to encrypt the data in the COS Bucket"
  type        = string
  default     = null
}

variable "key_protect_tags" {
  description = "Optional list of tags to be added to Key Protect instance."
  type        = list(string)
  default     = []
}

variable "cos_key_ring_name" {
  description = "A String containing the desired Key Ring Names as the key of the map for the key protect instance, this Key Protect Key is used to encrypt the data in the COS Bucket"
  type        = string
  default     = "cos-key-ring"
}

variable "cos_key_name" {
  description = "List of strings containing the list of desired Key Protect Key names as the values for each Key Ring, this Key Protect Key is used to encrypt the data in the COS Bucket"
  type        = list(string)
  default     = ["cos-key"]
}

variable "create_key_protect_key" {
  description = "Set as true to create a new Key Protect Key, this Key Protect Key is used to encrypt the COS Bucket"
  type        = bool
  default     = true
}

variable "key_protect_key_crn" {
  description = "CRN of the Key Protect Key to use if not creating a Key in this module, this Key Protect Key is used to encrypt the data in the COS Bucket"
  type        = string
  default     = null
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
