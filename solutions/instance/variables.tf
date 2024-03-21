variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "create_cos_instance" {
  description = "Set as true to create a new IBM Cloud-Object-Storage instance."
  type        = bool
  default     = true
}

variable "existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which Cloud-Object-Storage instance will be provisioned."
}

variable "create_resource_key" {
  description = "Set as true to create a new resource key for the Cloud-Object-Storage instance."
  type        = bool
  default     = false
}

variable "generate_hmac_credentials" {
  description = "Set as true to generate an HMAC key in the resource key. Only used when create_resource_key is `true`."
  type        = bool
  default     = false
}

variable "resource_key_name" {
  description = "The name of the resource key to be created."
  type        = string
  default     = "cos-resource-key"
}

variable "resource_key_role" {
  description = "The role you want to be associated with your new resource key. Valid roles are 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer'."
  type        = string
  default     = "Manager"
}

variable "cos_instance_name" {
  description = "The name of the IBM Cloud-Object-Storage instance. Only required if 'create_cos_instance' is true."
  type        = string
}

variable "cos_tags" {
  description = "Optional list of tags to be added to Cloud-Object-Storage instance. Only used if 'create_cos_instance' it true."
  type        = list(string)
  default     = []
}

variable "existing_cos_instance_id" {
  description = "The ID of an existing Cloud-Object-Storage instance. Required if 'var.create_cos_instance' is false."
  type        = string
  default     = null
}

variable "cos_plan" {
  description = "Plan to be used for creating Cloud-Object-Storage instance. Only used if 'create_cos_instance' it true."
  type        = string
  default     = "standard"
  # Validation happens in the fscloud module
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Cloud-Object-Storage instance."
  default     = []
}

variable "instance_cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    tags = optional(list(object({
      name  = string
      value = string
    })), [])
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "(Optional, list) List of CBR rule to create for the instance"
  default     = []
  # Validation happens in the CBR Rule module
}
