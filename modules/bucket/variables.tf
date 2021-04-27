#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

variable "bucket_name_prefix" {
  description = "Prefix used to generate the bucket name."
  type        = string
  default     = ""
}

variable "bucket_name" {
  type        = string
  description = "COS Bucket name"
}

variable "location" {
  description = "single site or region or cross region location info"
  type        = string
}

variable "storage_class" {
  description = " storage class to use for the bucket."
  type        = string
}

variable "cos_instance_id" {
  description = "Cos instance id"
  type        = string
}

variable "endpoint_type" {
  description = "endpoint for the COS bucket"
  type        = string
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
variable "archive_rule" {
  description = "Enable configuration archive_rule (glacier/accelerated) to COS Bucket after a defined period of time"
  type = object({
    rule_id = string
    enable  = bool
    days    = string
    type    = string
  })
  default = null
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


