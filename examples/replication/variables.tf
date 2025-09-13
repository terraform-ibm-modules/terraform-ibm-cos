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

# region needs to provide cross region support.
variable "region" {
  description = "Region where resources will be created"
  type        = string
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access tags to be added to the created resources"
  default     = []
}

variable "expire_days" {
  description = "The number of days before the expire rule action takes effect. Applies only if `create_cos_bucket` is set to `true`. If null is passed, no lifecycle configuration will be added for bucket expiration."
  type        = number
  default     = null
}

variable "archive_days" {
  description = "The number of days before the `archive_type` rule action takes effect. Applies only if `create_cos_bucket` is set to `true`. Set to `null` if you specify a bucket location in `cross_region_location` because archive data is not supported with cross-region buckets. If null is passed, no lifecycle configuration will be added for bucket archival."
  type        = number
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "The number of days after which non-current versions will be deleted. If null is passed, no lifecycle configuration will be added for bucket non-current version expiration."
  type        = number
  default     = null
}
