#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

variable "resource_group" {
  description = "Enter Name of the resource group"
  type        = string
}

variable "service_name" {
  description = "Enter Name of the cos instance"
  type        = string
}

variable "plan" {
  description = "Enter plan type"
  type        = string
}

variable "region" {
  description = " Enter Region for provisioning"
  type        = string
}

variable "provision_cos_instance" {
  description = "Create new cos instance (true/false)"
  type        = bool
  default     = true
}

variable "parameters" {
  type        = map(string)
  description = "Arbitrary parameters to pass cos instance"
  default     = null
}

variable "key_parameters" {
  type        = map(string)
  description = "Arbitrary parameters to pass to resourc key"
  default     = null
}

variable "bind_resource_key" {
  description = "Enable this to bind key to cos instance (true/false)"
  type        = bool
  default     = false
}

variable "resource_key_name" {
  description = "Name of the instance key"
  type        = string
  default     = ""
}

variable "role" {
  description = "Name of the user role (Valid roles are Writer, Reader, Manager, Administrator, Operator, Viewer, Editor.)"
  type        = string
  default     = ""
}

variable "key_tags" {
  type        = list(string)
  description = "Tags that should be applied to the key instance"
  default     = null
}


variable "tags" {
  type        = list(string)
  description = "Tags that should be applied to the service"
  default     = null
}

variable "service_endpoints" {
  description = "Types of the service endpoints ('public', 'private', 'public-and-private)"
  type        = string
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "Timeout duration for create."
  default     = null
}

variable "update_timeout" {
  type        = string
  description = "Timeout duration for update."
  default     = null
}

variable "delete_timeout" {
  type        = string
  description = "Timeout duration for delete."
  default     = null
}
