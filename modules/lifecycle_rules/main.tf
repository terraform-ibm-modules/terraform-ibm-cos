locals {
  # Assign deterministic rule IDs if not provided
  expiry_rules = [
    for idx, r in var.expiry_rules : merge(r, {
      rule_id = coalesce(try(r.rule_id, null), "expiry-rule-${idx}")
    })
  ]

  transition_rules = [
    for idx, r in var.transition_rules : merge(r, {
      rule_id       = coalesce(try(r.rule_id, null), "transition-rule-${idx}")
      storage_class = upper(r.storage_class)
    })
  ]

  noncurrent_expiry_rules = [
    for idx, r in var.noncurrent_expiry_rules : merge(r, {
      rule_id = coalesce(try(r.rule_id, null), "noncurrent-expiry-rule-${idx}")
    })
  ]

  abort_multipart_rules = [
    for idx, r in var.abort_multipart_rules : merge(r, {
      rule_id = coalesce(try(r.rule_id, null), "abort-multipart-rule-${idx}")
    })
  ]
}


resource "ibm_cos_bucket_lifecycle_configuration" "advance_bucket_lifecycle" {
  bucket_crn      = var.bucket_crn
  bucket_location = var.cos_region
  endpoint_type   = var.management_endpoint_type_for_bucket

  # Expiration rules
  dynamic "lifecycle_rule" {
    for_each = local.expiry_rules
    content {
      expiration {
        days = lifecycle_rule.value.days
      }
      filter {
        prefix = lifecycle_rule.value.prefix
      }
      rule_id = lifecycle_rule.value.rule_id
      status  = lifecycle_rule.value.status
    }
  }

  # Transition rules
  dynamic "lifecycle_rule" {
    for_each = local.transition_rules
    content {
      transition {
        days          = lifecycle_rule.value.days
        storage_class = lifecycle_rule.value.storage_class
      }
      filter {
        prefix = lifecycle_rule.value.prefix
      }
      rule_id = lifecycle_rule.value.rule_id
      status  = lifecycle_rule.value.status
    }
  }

    # Noncurrent version expiration rules
  dynamic "lifecycle_rule" {
    for_each = local.noncurrent_expiry_rules
    content {
      noncurrent_version_expiration {
        noncurrent_days = lifecycle_rule.value.noncurrent_days
      }
      filter {
        prefix = lifecycle_rule.value.prefix
      }
      rule_id = lifecycle_rule.value.rule_id
      status  = lifecycle_rule.value.status
    }
  }

  # Abort multipart rules
  dynamic "lifecycle_rule" {
    for_each = local.abort_multipart_rules
    content {
      abort_incomplete_multipart_upload {
        days_after_initiation = lifecycle_rule.value.days_after_initiation
      }
      filter {
        prefix = lifecycle_rule.value.prefix
      }
      rule_id = lifecycle_rule.value.rule_id
      status  = lifecycle_rule.value.status
    }
  }
 
}