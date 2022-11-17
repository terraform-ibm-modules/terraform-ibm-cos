variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
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

variable "region" {
  description = "Region where resources will be created"
  type        = string
  default     = "ca-tor"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}
