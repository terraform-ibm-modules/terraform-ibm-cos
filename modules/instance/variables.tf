#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

######## configured by user ########################

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "service_name" {
  description = "Name of the instance"
  type        = string
}

variable "plan" {
  description = "plan type"
  type        = string
}

variable "region" {
  description = "Provisioning Region"
  type        = string
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
  description = "Name of the key"
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
  description = "Tags that should be applied to the key"
  default     = null
}


variable "tags" {
  type        = list(string)
  description = "Tags that should be applied to the service"
  default     = null
}

variable "service_endpoints" {
  description = "Types of the service endpoints"
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

########### Having Default Values ############

variable "service_type" {
  description = "Type of the service"
  default     = "cloud-object-storage"
  type        = string
}

variable "provision_cos_instance" {
  description = "Would you like to create new cos instance"
  type        = bool
  default     = true
}



