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
  description = "Add user resource tags to the Cos instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types)."
  default     = []
}

variable "region" {
  description = "Region where resources will be created"
  type        = string
}

variable "hpcs_instance_crn" {
  description = "CRN of the Hyper Protect Crypto service instance to use to encrypt the data in the COS bucket and vault"
  type        = string
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "access_tags" {
  type        = list(string)
  description = "Add access management tags to the Cos instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)."
  default     = []
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to use to manage the bucket. (public, private or direct)"
  type        = string
  default     = "direct"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The specified management_endpoint_type_for_bucket is not a valid selection!"
  }
}
