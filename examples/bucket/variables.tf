#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

// Bucket congigurations

variable "location" {
  description = "single site or region or cross region location info"
  type        = string
}
variable "cos_location" {
  description = "cos location info"
  type        = string
}

variable "storage_class" {
  description = " storage class to use for the bucket."
  type        = string
}

variable "resource_group" {
  description = "Enter Name of the resource group"
  type        = string
}
variable "logdna_instance_name" {
  description = "Enter Name of the logdna instance name  with bucket to be configured for event"
  type        = string
}
variable "at_instance_name" {
  description = "Enter Name of the actvity tracker instance name  with bucket to be configured for event"
  type        = string
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

variable "allowed_ip" {
  description = "A list of IPv4 or IPv6 addresses in CIDR notation that you want to allow access to your IBM Cloud Object Storage bucket"
  type        = list(string)
  default     = null
}

variable "kms_key_crn" {
  description = "The CRN of the encryption root key that you want to use to encrypt data"
  type        = string
  default     = null
}

variable "cos_instance_name" {
  description = "Enter Name of the cos instance with bucket to be attached"
  type        = string
}
variable "endpoint_type" {
  description = "endpoint for the COS bucket"
  type        = string
  default     = "public"
}
variable "force_delete" {
  description = "COS buckets need to be empty before they can be deleted. force_delete option empty the bucket and delete it"
  type        = bool
  default     = true
}
variable "activity_tracker_crn" {
  description = "The instance crn of Activity Tracker that will receive object event data"
  default     = ""
}
variable "logdna_crn" {
  description = "The instance crn of logdna that will receive object event data"
  default     = ""
}
variable "read_data_events" {
  description = "If set to true, all object read events will be sent to Activity Tracker/logdna"
  type        = bool
  default     = true

}
variable "write_data_events" {
  description = "If set to true, all object write events will be sent to Activity Tracke/logdna"
  type        = bool
  default     = true

}
variable "cos_plan" {
  description = "Enter plan type for cos "
  type        = string
}


