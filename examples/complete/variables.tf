variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "prefix" {
  type        = string
  default     = "test-cos"
  description = "Prefix name for all related resources"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

# region needs to provide cross region support.
variable "region" {
  description = "Region where resources will be created"
  type        = string
  default     = "us-south"

  validation {
    condition     = can(regex("us-south|eu-de|jp-tok", var.region))
    error_message = "Variable 'region' must be 'us-south' or 'eu-de', or 'jp-tok'. The encryption key must be created in a high availability key protect instance for cross region object storage"
  }
}

variable "cross_region_location" {
  description = "Specify the cross-regional bucket location. Supported values are 'us', 'eu', and 'ap'."
  type        = string
  default     = "us"

  validation {
    condition     = can(regex("us|eu|ap", var.cross_region_location))
    error_message = "Variable 'cross_region_location' must be 'us' or 'eu', or 'ap'."
  }
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "existing_at_instance_crn" {
  type        = string
  description = "Optionally pass an existing activity tracker instance CRN to use in the example. If not passed, a new instance will be provisioned"
  default     = null
}

variable "cos_plan" {
  description = "Plan to be used for creating cloud object storage instance. Only used if 'create_cos_instance' it true."
  type        = string
  default     = "cos-one-rate-plan"
}

variable "bucket_storage_class" {
  description = "Storage plan to be applied to your cos instance, only valid one rate plan storage class."
  type        = string
  default     = "onerate_active"
}
