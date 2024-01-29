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

variable "region" {
  description = "Region where resources will be created"
  type        = string
}

variable "bucket_existing_hpcs_instance_guid" {
  description = "The GUID of the Hyper Protect Crypto service in which the key specified in var.hpcs_key_crn is coming from"
  type        = string
}

variable "bucket_hpcs_key_crn" {
  description = "CRN of the Hyper Protect Crypto service to use to encrypt the data in the COS bucket"
  type        = string
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "existing_at_instance_crn" {
  type        = string
  description = "Optionally pass an existing activity tracker instance CRN to use in the example. If not passed, a new instance will be provisioned"
  #default     = null
}

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access tags to be added to the created resources"
  default     = []
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to use to manage the bucket. (public, private or direct)"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The specified management_endpoint_type_for_bucket is not a valid selection!"
  }
}
