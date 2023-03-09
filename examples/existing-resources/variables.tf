variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "Name of the Region to deploy in to"
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  default     = "exist-cos"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "bucket_names" {
  type        = list(string)
  description = "List of buckets to be created"

  validation {
    condition     = length(var.bucket_names) > 0
    error_message = "Please provide list of buckets to be created"
  }
}
