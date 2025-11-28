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
variable "noncurrent_expiry_rules" {
  description = "List of noncurrent version expiration rules , note : this lifecycle rule requires object versioning make sure object versioning is enabled on the bucket"
  type = list(object({
    rule_id         = optional(string)
    status          = optional(string, "enable")
    noncurrent_days = number
    prefix          = optional(string, "")
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.noncurrent_expiry_rules : try(r.noncurrent_days, 0) >= 1])
    error_message = "Each noncurrent version expiration rule must have noncurrent_days >= 1."
  }
}

variable "abort_multipart_rules" {
  description = "List of abort incomplete multipart upload rules"
  type = list(object({
    rule_id               = optional(string)
    status                = optional(string, "enable")
    days_after_initiation = number
    prefix                = optional(string, "")
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.abort_multipart_rules : try(r.days_after_initiation, 0) >= 1])
    error_message = "Each abort multipart rule must have days_after_initiation >= 1."
  }
}
