variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix name for all related resources"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access tags to be added to the created resources"
  default     = []
}

# region needs to provide cross region support.
variable "region" {
  description = "Region where resources will be created"
  type        = string

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

variable "single_site_location" {
  type        = string
  description = "Specify the single site bucket location. If you pass a value for this, ensure to set the value of var.region and var.cross_region_location to null."
  default     = "ams03"

  validation {
    condition     = var.single_site_location == null || can(regex("ams03|mil01|mon01|par01|sjc04|sng01|che01", var.single_site_location))
    error_message = "Variable 'cross_region_location' must be 'ams03', 'mil01', 'mon01', 'par01', 'sjc04', 'sng01', 'che01' or 'null'."
  }
}

variable "management_endpoint_type_for_bucket" {
  type        = string
  description = "The type of endpoint for the IBM terraform provider to use to manage the bucket. (public, private, direct)"
  default     = "public"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}
