variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy IAM-enabled resources."
  sensitive   = true
}

variable "existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which Cloud Object Storage instance will be provisioned."
}

variable "resource_keys" {
  description = "The definition of any resource keys to be generated."
  type = list(object({
    name                      = string
    generate_hmac_credentials = optional(bool, false)
    role                      = optional(string, "Reader")
    service_id_crn            = optional(string, null)
  }))
  default = []
}

variable "cos_instance_name" {
  description = "The name of the IBM Cloud Object Storage instance."
  type        = string
  default     = "cos-instance"
}

variable "cos_tags" {
  description = "Optional list of tags to be added to Cloud Object Storage instance."
  type        = list(string)
  default     = []
}

variable "cos_plan" {
  description = "Plan to be used for creating Cloud Object Storage instance."
  type        = string
  default     = "standard"
  # Validation happens in the fscloud module
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Cloud Object Storage instance."
  default     = []
}
