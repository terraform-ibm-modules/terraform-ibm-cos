variable "bucket_crn" {
  description = "The CRN of an existing Cloud Object Storage bucket."
  type        = string
}

variable "cos_region" {
  description = "The region of existing Cloud Object Storage bucket."
  type        = string
}

variable "management_endpoint_type_for_bucket" {
  description = "The type of endpoint for the IBM terraform provider to manage the bucket. Possible values are `public`, `private`, or `direct`."
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private", "direct"], var.management_endpoint_type_for_bucket)
    error_message = "The value isn't valid. Possible values are `public`, `private`, or `direct`."
  }
}

variable "cross_region_location" {
  description = "Specify the cross-region bucket location. Possible values are `us`, `eu`, or `ap`. If specified, set `region` and `single_site_location` to `null`."
  type        = string
  default     = null
}

variable "object_versioning_enabled" {
  description = "Whether to enable object versioning to keep multiple versions of an object in a bucket."
  type        = bool
  default     = false
}

variable "expiry_rules" {
  description = "List of expiry rules"
  type = list(object({
    rule_id = optional(string)
    status  = optional(string, "enable")
    days    = number
    prefix  = optional(string, "")
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.expiry_rules : r.days >= 1])
    error_message = "Expiry days must be >= 1."
  }   


}

variable "transition_rules" {
  description = "List of transition rules (archival)"
  type = list(object({
    rule_id       = optional(string)
    status        = optional(string, "enable")
    days          = number
    storage_class = string            
    prefix        = optional(string, "")
  }))
  default = []
  
  validation {
    condition = (
      var.cross_region_location == null ||
      length(var.transition_rules) == 0
    )
    error_message = "If `cross_region_location` is set, you cannot configure transition (archive) rules because archive data is not supported with cross-region buckets"
  }
}

variable "noncurrent_expiry_rules" {
  description = "List of noncurrent version expiration rules"
  type = list(object({
    rule_id          = optional(string)
    status           = optional(string, "enable")
    noncurrent_days  = number
    prefix           = optional(string, "")
  }))
  default = []
   
    validation {
    condition     = length(var.noncurrent_expiry_rules) == 0 || var.object_versioning_enabled == true
    error_message = "Noncurrent version expiration lifecycle rule requires object versioning. Make sure `object_versioning_enabled` is set to `true`."
  }

   validation {
    condition     = alltrue([for r in var.noncurrent_expiry_rules : try(r.noncurrent_days, 0) >= 1])
    error_message = "Each noncurrent version expiration rule must have noncurrent_days >= 1."
  }
}

variable "abort_multipart_rules" {
  description = "List of abort incomplete multipart upload rules"
  type = list(object({
    rule_id                 = optional(string)
    status                  = optional(string, "enable")
    days_after_initiation   = number
    prefix                  = optional(string, "")
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.abort_multipart_rules : try(r.days_after_initiation, 0) >= 1])
    error_message = "Each abort multipart rule must have days_after_initiation >= 1."
  }
}

