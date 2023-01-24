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
}

variable "cross_region_location" {
  description = "Specify the cross-regional bucket location. Supported values are 'us', 'eu', and 'ap'."
  type        = string
  default     = "us"

  validation {
    condition     = var.cross_region_location == null || can(regex("us|eu|ap", var.cross_region_location))
    error_message = "Variable 'cross_region_location' must be 'us' or 'eu', 'ap', or 'null'."
  }
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "existing_at_instance_crn" {
  type        = string
  description = "Activity tracker crn for COS bucket. Using permanent instance as region is hardcoded in tests/pr_test.go."
  default     = null
}
