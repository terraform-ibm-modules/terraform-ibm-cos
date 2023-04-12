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
