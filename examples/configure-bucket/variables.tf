#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

/***************************************************
Read resource group
***************************************************/

variable "resource_group" {
  description = "Enter name of the resource group"
  type        = string
}

/*****************************************************
activity_tracker instance
*****************************************************/

variable "configure_activity_tracker" {
  description = "Enable this to bind activity tracket to COS bucket"
  type        = bool
  default     = true
}

variable "is_new_activity_tracker" {
  description = "Enable this to create new activity tracker instance"
  type        = bool
  default     = true
}

variable "activity_tracker_name" {
  description = "Enter activity_tracker name "
  type        = string
}

variable "activity_tracker_plan" {
  description = "The type of plan for activity tracker (lite, 7-day, 14-day, or 30-day)"
  type        = string
  default     = "7-day"
}

variable "activity_tracker_region" {
  description = "Enter the region to provision activity_tracker "
  type        = string
  default     = "us-south"
}

/*****************************************************
sysdig monitoring instance
*****************************************************/

variable "configure_sysdig_monitoring" {
  description = "Enable this to bind sysdig_monitoring to COS bucket"
  type        = bool
  default     = true
}

variable "is_new_sysdig_monitoring" {
  description = "Enable this to create new sysdig_monitoring instance"
  type        = bool
  default     = true
}

variable "sysdig_monitoring_name" {
  description = "Enter sysdig_monitoring name "
  type        = string
}

variable "sysdig_monitoring_plan" {
  description = "plan type (graduated-tier, graduated-tier-sysdig-secure-plus-monitor and lite)"
  type        = string
  default     = "graduated-tier"
}

variable "sysdig_monitoring_region" {
  description = "Enter the region to provision sysdig_monitoring "
  type        = string
}

/*****************************************************
COS Instance
*****************************************************/

variable "is_new_cos_instance" {
  description = "Enable this to create new cos instance"
  type        = bool
  default     = true
}

variable "cos_instance_name" {
  description = "Enter Name of the cos instance with bucket to be attached"
  type        = string
}

variable "region" {
  description = "cos location info"
  type        = string
  default     = "global"
}

variable "plan" {
  description = "Enter plan type for cos "
  type        = string
  default     = "standard"
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

variable "is_bind_resource_key" {
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

variable "hmac_credential" {
  type        = bool
  description = "Users can create a set of HMAC credentials"
  default     = false
}

/*****************************************************
COS Bucket
*****************************************************/

variable "bucket_name_prefix" {
  description = "Prefix used to generate the bucket name."
  type        = string
  default     = "cos-bucket"
}

variable "bucket_names" {
  description = " List of buckets to create."
  type        = list(string)
}

variable "location" {
  description = "single site or region or cross region location info"
  type        = string
}

variable "storage_class" {
  description = "Storage class to use for the bucket."
  type        = string
  default     = "standard"
}

variable "endpoint_type" {
  description = "Endpoint for the COS bucket"
  type        = string
  default     = "public"
}

variable "force_delete" {
  description = "COS buckets need to be empty before they can be deleted. force_delete option empty the bucket and delete it"
  type        = bool
  default     = true
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

variable "key_tags" {
  type        = list(string)
  description = "Tags that should be applied to the key"
  default     = null
}

variable "archive_rule_enabled" {
  description = "Set this to true only for regional cos bucket creation.(for cross region and singleSite location set to false)"
  type        = bool
  default     = false
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

variable "usage_metrics_enabled" {
  description = "Usage metrics will be sent to the monitoring service."
  type        = bool
  default     = null
}





