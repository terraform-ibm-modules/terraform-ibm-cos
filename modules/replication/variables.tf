##############################################################################
# Source bucket variables
##############################################################################

variable "source_bucket_crn" {
  type        = string
  description = "The CRN of the source bucket. The instance GUID, bucket name, and account ID are parsed from this CRN."
}

variable "source_bucket_region" {
  type        = string
  description = "The region of the source bucket."
}

variable "bucket_endpoint_type" {
  type        = string
  description = "The endpoint type of the bucket. Possible values are `public`, `private`, or `direct`."
  default     = "public"

  validation {
    condition     = contains(["public", "private", "direct"], var.bucket_endpoint_type)
    error_message = "The value isn't valid. Possible values are `public`, `private`, or `direct`."
  }
}

##############################################################################
# Replication rules variables
##############################################################################

variable "replication_rules" {
  type = list(object({
    rule_id                         = string
    enable                          = bool
    priority                        = optional(number)
    prefix                          = optional(string)
    deletemarker_replication_status = optional(bool)
    destination_bucket_crn          = string
    skip_iam_authorization_policy   = optional(bool, false)
  }))
  description = <<-EOT
    List of replication rules to configure. Each rule requires:
    - rule_id: Unique identifier for the rule.
    - enable: Whether the rule is enabled.
    - priority: (Optional) Priority of the rule, higher number = higher priority.
    - prefix: (Optional) Prefix filter to replicate a subset of objects in the source bucket.
    - deletemarker_replication_status: (Optional) Whether to replicate delete markers.
    - destination_bucket_crn: The CRN of the destination bucket. The target COS instance GUID and target bucket name are parsed from this CRN.
    - skip_iam_authorization_policy: (Optional) Set it to `true` to skip IAM policy creation for this rule. Default value is `false`.
  EOT

  validation {
    condition     = length(var.replication_rules) == length(distinct([for rule in var.replication_rules : rule.rule_id]))
    error_message = "Each replication rule must have a unique rule_id."
  }
  validation {
    condition     = length(var.replication_rules) >= 1 && length(var.replication_rules) <= 1000
    error_message = "At least one replication rule must be provided and a maximum of 1000 replication rules can be configured for a bucket."
  }
}
