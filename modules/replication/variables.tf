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
  description = "The location/region of the source bucket"
}

variable "source_bucket_name" {
  type        = string
  description = "The name of the source bucket"
}

variable "source_cos_instance_guid" {
  type        = string
  description = "The GUID of the source COS instance"
}

##############################################################################
# Target bucket variables
##############################################################################

variable "target_bucket_crn" {
  type        = string
  description = "The CRN of the target/destination bucket"
}

variable "target_bucket_name" {
  type        = string
  description = "The name of the target bucket"
}

variable "target_cos_instance_guid" {
  type        = string
  description = "The GUID of the target COS instance"
}

##############################################################################
# Replication rule variables
##############################################################################

variable "replication_rule_id" {
  type        = string
  description = "The ID/name for the replication rule"
  default     = "replicate-everything"
}

variable "replication_enabled" {
  type        = bool
  description = "Whether to enable the replication rule"
  default     = true
}

variable "replication_priority" {
  type        = number
  description = "The priority of the replication rule (higher number = higher priority)"
  default     = 50
}

variable "deletemarker_replication_status" {
  type        = bool
  description = "Whether to replicate delete markers"
  default     = false
}

##############################################################################
# IAM authorization policy variables
##############################################################################

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Whether to skip the IAM authorization policy for replication. Set to true if the policy already exists."
  default     = false
}
