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

