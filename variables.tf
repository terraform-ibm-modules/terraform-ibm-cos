variable "is_new_cos_instance" {
  description = "Enable this to create new cos instance"
  type        = bool
  default     = true
}

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "cos_instance_name" {
  description = "Name of cos instance"
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

variable "is_bind_resource_key" {
  description = "Enable this to bind key to cos instance (true/false)"
  type        = bool
  default     = false
}

variable "resource_key_name" {
  description = "Name of the key"
  type        = string
  default     = ""
}

variable "hmac_credential" {
  type        = bool
  description = "Users can create a set of HMAC credentials"
  default     = false
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

#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

variable "is_new_cos_bucket" {
  description = "Enable this to create new cos bucket(s)"
  type        = bool
  default     = true
}

variable "bucket_name_prefix" {
  description = "Prefix used to generate the bucket name."
  type        = string
  default     = ""
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
}

variable "kms_key_crn" {
  description = "The CRN of the encryption root key that you want to use to encrypt data"
  type        = string
  default     = null
}

variable "endpoint_type" {
  description = "Endpoint for the COS bucket"
  type        = string
  default     = null
}

variable "allowed_ip" {
  description = "A list of IPv4 or IPv6 addresses in CIDR notation that you want to allow access to your IBM Cloud Object Storage bucket"
  type        = list(string)
  default     = null
}

variable "force_delete" {
  description = "COS buckets need to be empty before they can be deleted. force_delete option empty the bucket and delete it"
  type        = bool
  default     = null
}

variable "read_data_events" {
  description = "If set to true, all object read events will be sent to Activity Tracker/logdna"
  type        = bool
  default     = null

}
variable "write_data_events" {
  description = "If set to true, all object write events will be sent to Activity Tracke/logdna"
  type        = bool
  default     = null

}
variable "activity_tracker_crn" {
  description = "The instance of Activity Tracker/logdna that will receive object event data"
  default     = ""
}


variable "usage_metrics_enabled" {
  description = "Usage metrics will be sent to the monitoring service."
  type        = bool
  default     = null
}

variable "metrics_monitoring_crn" {
  description = "Instance of IBM Cloud Monitoring that will receive the bucket metrics"
  default     = ""
}
variable "archive_rules" {
  description = "Enable configuration archive_rule (glacier/accelerated) to COS Bucket after a defined period of time"
  type = list(object({
    rule_id = string
    enable  = bool
    days    = string
    type    = string
  }))
  default = []
}

variable "expire_rules" {
  description = "Enable configuration expire_rule to COS Bucket after a defined period of time"
  type = list(object({
    rule_id = string
    enable  = bool
    days    = string
    prefix  = string
  }))
  default = []
}



