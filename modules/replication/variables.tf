##############################################################################
# Common variables
##############################################################################

##############################################################################
# Source bucket variables
##############################################################################

variable "source_bucket_crn" {
  type        = string
  description = "The CRN of the source bucket"
}

variable "source_bucket_location" {
  type        = string
  description = "The region of the source bucket"
}

variable "source_bucket_name" {
  type        = string
  description = "The name of the source bucket"
}

variable "source_cos_instance_guid" {
  type        = string
  description = "The GUID of the source COS instance"
}

variable "bucket_endpoint_type" {
  type        = string
  description = "The endpoint type of the bucket"
  default     = "public"
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
    target_cos_instance_guid        = string
    target_bucket_name              = string
    skip_iam_authorization_policy   = optional(bool, false)
  }))
  description = <<-EOT
    List of replication rules to configure. Each rule requires:
    - rule_id: Unique identifier for the rule
    - enable: Whether the rule is enabled
    - priority: Priority of the rule, higher number = higher priority
    - prefix: Optional prefix filter to replicate a subset of objects in the source bucket
    - deletemarker_replication_status: Whether to replicate delete markers
    - destination_bucket_crn: The CRN of the destination bucket
    - target_cos_instance_guid: GUID of the target COS instance (for IAM policy)
    - target_bucket_name: Name of the target bucket (for IAM policy)
  EOT

  validation {
    condition     = length(var.replication_rules) == length(distinct([for rule in var.replication_rules : rule.rule_id]))
    error_message = "Each replication rule must have a unique rule_id."
  }
  validation {
    condition     = length(var.replication_rules) <= 1000
    error_message = "A maximum of 1000 replication rules can be configured for a bucket."
  }
}

##############################################################################
# IAM authorization policy variables
##############################################################################

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to skip the IAM authorization policy for replication. Set to true if the policy already exists."
  default     = false
}
