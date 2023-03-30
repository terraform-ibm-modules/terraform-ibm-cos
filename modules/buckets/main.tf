##############################################################################
# terraform-ibm-cos
#
# Create COS buckets
##############################################################################

locals {
  # input variable validation
  # tflint-ignore: terraform_unused_declarations
  # validate_key_inputs = var.create_cos_bucket && var.encryption_enabled && var.kms_key_crn == null ? tobool("A value must be passed for var.kms_key_crn when both var.create_cos_bucket and var.encryption_enabled are true") : true
}

# Create COS buckets from bucket_configs
resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name           = var.bucket_configs[0].bucket_name
  resource_instance_id  = var.bucket_configs[0].resource_instance_id
  region_location       = var.bucket_configs[0].region_location
  cross_region_location = var.bucket_configs[0].cross_region_location
  storage_class         = var.bucket_configs[0].storage_class
  key_protect           = var.bucket_configs[0].kms_key_crn
  ## This for_each block is NOT a loop to attach to multiple retention blocks.
  ## This block is only used to conditionally add retention block depending on retention is enabled.
  dynamic "retention_rule" {
    for_each = []
    content {
      default   = var.bucket_configs[0].retention_rule.default
      maximum   = var.bucket_configs[0].retention_rule.maximum
      minimum   = var.bucket_configs[0].retention_rule.minimum
      permanent = var.bucket_configs[0].retention_rule.permanent
    }
  }
  ## This for_each block is NOT a loop to attach to multiple archive blocks.
  ## This block is only used to conditionally add retention block depending on archive rule is enabled.
  dynamic "archive_rule" {
    for_each = []
    content {
      enable = true
      days   = var.bucket_configs[0].archive_rule.days
      type   = var.bucket_configs[0].archive_rule.type
    }
  }
  ## This for_each block is NOT a loop to attach to multiple expire blocks.
  ## This block is only used to conditionally add retention block depending on expire rule is enabled.
  dynamic "expire_rule" {
    for_each = []
    content {
      enable = true
      days   = var.expire_days
    }
  }
  ## This for_each block is NOT a loop to attach to multiple Activity Tracker instances.
  ## This block is only used to conditionally attach activity tracker depending on AT CRN is provided.
  dynamic "activity_tracking" {
    for_each = []
    content {
      read_data_events     = true
      write_data_events    = true
      activity_tracker_crn = var.activity_tracker_crn
    }
  }
  ## This for_each block is NOT a loop to attach to multiple Sysdig instances.
  ## This block is only used to conditionally attach monitoring depending on Sydig CRN is provided.
  dynamic "metrics_monitoring" {
    for_each = []
    content {
      usage_metrics_enabled   = true
      request_metrics_enabled = true
      metrics_monitoring_crn  = var.sysdig_crn
    }
  }
  ## This for_each block is NOT a loop to attach to multiple versioning blocks.
  ## This block is only used to conditionally attach a single versioning block.
  dynamic "object_versioning" {
    for_each = []
    content {
      enable = var.object_versioning_enabled
    }
  }
}

locals {
  cos_instance_guid = element(split(":", var.bucket_configs[0].resource_instance_id), length(split(":", var.bucket_configs[0].resource_instance_id)) - 3)
  bucket_name       = var.bucket_configs[0].bucket_name
  cbr_rules = (length(var.bucket_configs[0].cbr_rules) > 0) ? [

    # returns a set containing rules and the bucket to which the rules to be applied to
    for pair in setproduct(var.bucket_configs[0].cbr_rules, toset(local.bucket_name)) : {
      cbr_rule_block = pair[0]
      bucket_name    = pair[1]
    }
  ] : []
}

##############################################################################
# Context Based Restrictions
##############################################################################

module "bucket_cbr_rule" {
  # generates a map with bucket name as key and cbr rule for bucket as value
  for_each = {
    for bucket_rule in local.cbr_rules : bucket_rule.bucket_name => bucket_rule
  }

  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-rule-module?ref=v1.2.0"
  rule_description = each.value.cbr_rule_block.description
  enforcement_mode = each.value.cbr_rule_block.enforcement_mode
  rule_contexts    = each.value.cbr_rule_block.rule_contexts

  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = each.value.cbr_rule_block.account_id
        operator = "stringEquals"
      },
      {
        name     = "resource"
        value    = each.value.bucket_name
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = local.cos_instance_guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
      }
    ],
    tags = each.value.cbr_rule_block.tags
  }]
  operations = each.value.cbr_rule_block.operations == null ? [] : each.value.cbr_rule_block.operations
}
