variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "prefix" {
  type        = string
  default     = "test-cos-fscloud"
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
  default     = "us-south"
}

variable "primary_region" {
  description = "region for the primary bucket"
  type        = string
  default     = "us-south"
}

variable "secondary_region" {
  description = "region for the secondary bucket"
  type        = string
  default     = "us-east"
}

variable "primary_existing_hpcs_instance_guid" {
  description = "The GUID of the Hyper Protect Crypto service in which the key specified in var.hpcs_key_crn is coming from. If not set a Key Protect instance will be used for demo purposes but will not be FS cloud compliant"
  type        = string
  default     = null
}

variable "secondary_existing_hpcs_instance_guid" {
  description = "The GUID of the Hyper Protect Crypto service in which the key specified in var.hpcs_key_crn is coming from. If not set a Key Protect instance will be used for demo purposes but will not be FS cloud compliant"
  type        = string
  default     = null
}

variable "primary_hpcs_key_crn" {
  description = "CRN of the Hyper Protect Crypto service to use to encrypt the data in the COS Bucket. If not set a Key Protect key will be created and used for demo purposes but will not be FS cloud compliant"
  type        = string
  default     = null
}

variable "secondary_hpcs_key_crn" {
  description = "CRN of the Hyper Protect Crypto service to use to encrypt the data in the COS Bucket. If not set a Key Protect key will be created and used for demo purposes but will not be FS cloud compliant"
  type        = string
  default     = null
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
