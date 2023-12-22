variable "replication_rule" {
  type = object({
    rule_id                         = optional(string)
    enable                          = optional(bool)
    prefix                          = optional(string)
    priority                        = optional(number)
    deletemarker_replication_status = optional(bool)
  })
  description = "Rule for replication"
  default     = {}
}

variable "origin_bucket_crn" {
  type        = string
  description = "The CRN of the origin bucket"
}

variable "origin_bucket_location" {
  type        = string
  description = "The origin bucket location"
}

variable "origin_bucket_instance_guid" {
  type        = string
  description = "The COS instance GUID of the origin bucket"
}

variable "origin_bucket_name" {
  type        = string
  description = "The name of the origin bucket"
  default     = null
}

variable "destination_bucket_crn" {
  type        = string
  description = "The CRN of the destination bucket"
  default     = null
}

variable "destination_bucket_instance_guid" {
  type        = string
  description = "The COS instance GUID of the destination bucket"
  default     = null
}

variable "destination_bucket_name" {
  type        = string
  description = "The name of the destination bucket"
  default     = null
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Skip creation of authorization policy"
  default     = false
}
