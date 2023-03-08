##############################################################################
# terraform-ibm-cos
#
# Creates COS instance and buckets
##############################################################################

locals {
  at_enabled                = var.activity_tracker_crn == null ? [] : [1]
  metrics_enabled           = var.sysdig_crn == null ? [] : [1]
  archive_enabled           = var.archive_days == null ? [] : [1]
  expire_enabled            = var.expire_days == null ? [] : [1]
  retention_enabled         = var.retention_enabled ? [1] : []
  object_versioning_enabled = var.object_versioning_enabled ? [1] : []

  # input variable validation
  # tflint-ignore: terraform_unused_declarations
  validate_encryption_inputs = !var.create_cos_instance && !var.create_cos_bucket ? tobool("var.create_cos_instance and var.create_cos_bucket cannot be both set to false") : true
  # tflint-ignore: terraform_unused_declarations
  validate_key_inputs = var.create_cos_bucket && var.encryption_enabled && var.key_protect_key_crn == null ? tobool("A value must be passed for var.key_protect_key_crn when both var.create_cos_bucket and var.encryption_enabled are true") : true
  # tflint-ignore: terraform_unused_declarations
  validate_bucket_inputs = var.create_cos_bucket && length(var.bucket_names) == 0 ? tobool("If var.create_cos_bucket is true, then provide value for var.bucket_names") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cos_inputs = var.create_cos_instance && var.cos_instance_name == null ? tobool("If var.create_cos_instance is true, then provide value for var.cos_instance_name") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cos_id_input = !var.create_cos_instance && var.existing_cos_instance_id == null ? tobool("If var.create_cos_instance is false, then provide a value for var.existing_cos_instance_id to create buckets") : true
  # tflint-ignore: terraform_unused_declarations
  validate_kp_guid_input = var.encryption_enabled && var.create_cos_instance && var.existing_key_protect_instance_guid == null ? tobool("A value must be passed for var.existing_key_protect_instance_guid when var.create_cos_instance and var.encryption_enabled is true.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cross_region_location_inputs = var.create_cos_bucket && ((var.cross_region_location == null && var.region == null) || (var.cross_region_location != null && var.region != null)) ? tobool("If var.create_cos_bucket is true, then value needs to be provided for var.cross_region_location or var.region, but not both") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cross_region_location_archive_disabled_inputs = var.create_cos_bucket && (var.cross_region_location != null && var.archive_days != null) ? tobool("If var.cross_region_location is set, then var.expire_days cannot be set.") : true
}

# Resource to create COS instance if create_cos_instance is true
resource "ibm_resource_instance" "cos_instance" {
  count             = var.create_cos_instance ? 1 : 0
  name              = var.cos_instance_name
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = var.cos_location
  tags              = var.cos_tags
}

resource "ibm_resource_key" "resource_key" {
  count                = var.create_hmac_key && var.create_cos_instance ? 1 : 0
  name                 = var.hmac_key_name
  resource_instance_id = ibm_resource_instance.cos_instance[count.index].id
  parameters = {
    "serviceid_crn" = var.resource_key_existing_serviceid_crn
    "HMAC"          = var.create_hmac_key
  }
  role = var.hmac_key_role
}

locals {
  cos_instance_id      = var.create_cos_instance == true ? tolist(ibm_resource_instance.cos_instance[*].id)[0] : var.existing_cos_instance_id
  cos_instance_guid    = var.create_cos_instance == true ? tolist(ibm_resource_instance.cos_instance[*].guid)[0] : element(split(":", var.existing_cos_instance_id), length(split(":", var.existing_cos_instance_id)) - 3)
  create_access_policy = var.encryption_enabled && var.create_cos_instance && !var.skip_iam_authorization_policy
}

# Create IAM Authorization Policy to allow COS to access key protect for the encryption key
resource "ibm_iam_authorization_policy" "policy" {
  count                       = local.create_access_policy ? 1 : 0
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  target_service_name         = "kms"
  target_resource_instance_id = var.existing_key_protect_instance_guid
  roles                       = ["Reader"]
}

# Create COS bucket with:
# - Retention
# - Encryption
# - Monitoring
# - Activity Tracking
# - Versioning

resource "ibm_cos_bucket" "cos_bucket" {
  count                 = (var.encryption_enabled && var.create_cos_bucket) ? length(var.bucket_names) : 0
  depends_on            = [ibm_iam_authorization_policy.policy]
  bucket_name           = var.bucket_names[count.index]
  resource_instance_id  = local.cos_instance_id
  region_location       = var.region
  cross_region_location = var.cross_region_location
  endpoint_type         = var.bucket_endpoint
  storage_class         = var.bucket_storage_class
  key_protect           = var.key_protect_key_crn
  ## This for_each block is NOT a loop to attach to multiple retention blocks.
  ## This block is only used to conditionally add retention block depending on retention is enabled.
  dynamic "retention_rule" {
    for_each = local.retention_enabled
    content {
      default   = var.retention_default
      maximum   = var.retention_maximum
      minimum   = var.retention_minimum
      permanent = var.retention_permanent
    }
  }
  ## This for_each block is NOT a loop to attach to multiple archive blocks.
  ## This block is only used to conditionally add retention block depending on archive rule is enabled.
  dynamic "archive_rule" {
    for_each = local.archive_enabled
    content {
      enable = true
      days   = var.archive_days
      type   = var.archive_type
    }
  }
  ## This for_each block is NOT a loop to attach to multiple expire blocks.
  ## This block is only used to conditionally add retention block depending on expire rule is enabled.
  dynamic "expire_rule" {
    for_each = local.expire_enabled
    content {
      enable = true
      days   = var.expire_days
    }
  }
  ## This for_each block is NOT a loop to attach to multiple Activity Tracker instances.
  ## This block is only used to conditionally attach activity tracker depending on AT CRN is provided.
  dynamic "activity_tracking" {
    for_each = local.at_enabled
    content {
      read_data_events     = true
      write_data_events    = true
      activity_tracker_crn = var.activity_tracker_crn
    }
  }
  ## This for_each block is NOT a loop to attach to multiple Sysdig instances.
  ## This block is only used to conditionally attach monitoring depending on Sydig CRN is provided.
  dynamic "metrics_monitoring" {
    for_each = local.metrics_enabled
    content {
      usage_metrics_enabled   = true
      request_metrics_enabled = true
      metrics_monitoring_crn  = var.sysdig_crn
    }
  }
  ## This for_each block is NOT a loop to attach to multiple versioning blocks.
  ## This block is only used to conditionally attach a single versioning block.
  dynamic "object_versioning" {
    for_each = local.object_versioning_enabled
    content {
      enable = var.object_versioning_enabled
    }
  }
}

# Create COS bucket with:
# - Retention
# - Monitoring
# - Activity Tracking
# - Versioning
# Create COS bucket without:
# - Encryption
resource "ibm_cos_bucket" "cos_bucket1" {
  count                 = (!var.encryption_enabled && var.create_cos_bucket) ? length(var.bucket_names) : 0
  bucket_name           = var.bucket_names[count.index]
  resource_instance_id  = local.cos_instance_id
  region_location       = var.region
  cross_region_location = var.cross_region_location
  endpoint_type         = var.bucket_endpoint
  storage_class         = var.bucket_storage_class
  dynamic "retention_rule" {
    for_each = local.retention_enabled
    content {
      default   = var.retention_default
      maximum   = var.retention_maximum
      minimum   = var.retention_minimum
      permanent = var.retention_permanent
    }
  }
  dynamic "archive_rule" {
    for_each = local.archive_enabled
    content {
      enable = true
      days   = var.archive_days
      type   = var.archive_type
    }
  }
  dynamic "expire_rule" {
    for_each = local.expire_enabled
    content {
      enable = true
      days   = var.expire_days
    }
  }
  ## This for_each block is NOT a loop to attach to multiple Activity Tracker instances.
  ## This block is only used to conditionally attach activity tracker depending on AT CRN is provided.
  dynamic "activity_tracking" {
    for_each = local.at_enabled
    content {
      read_data_events     = true
      write_data_events    = true
      activity_tracker_crn = var.activity_tracker_crn
    }
  }
  ## This for_each block is NOT a loop to attach to multiple Sysdig instances.
  ## This block is only used to conditionally attach monitoring depending on Sydig CRN is provided.
  dynamic "metrics_monitoring" {
    for_each = local.metrics_enabled
    content {
      usage_metrics_enabled   = true
      request_metrics_enabled = true
      metrics_monitoring_crn  = var.sysdig_crn
    }
  }
  ## This for_each block is NOT a loop to attach to multiple versioning blocks.
  ## This block is only used to conditionally attach a single versioning block.
  dynamic "object_versioning" {
    for_each = local.object_versioning_enabled
    content {
      enable = var.object_versioning_enabled
    }
  }
}

locals {
  bucket_crn           = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].crn : ibm_cos_bucket.cos_bucket1[*].crn
  bucket_id            = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].id : ibm_cos_bucket.cos_bucket1[*].id
  bucket_name          = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].bucket_name : ibm_cos_bucket.cos_bucket1[*].bucket_name
  bucket_storage_class = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].storage_class : ibm_cos_bucket.cos_bucket1[*].storage_class
  s3_endpoint_public   = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].s3_endpoint_public : ibm_cos_bucket.cos_bucket1[*].s3_endpoint_public
  s3_endpoint_private  = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].s3_endpoint_private : ibm_cos_bucket.cos_bucket1[*].s3_endpoint_private
  cbr_rules = (length(var.bucket_cbr_rules) > 0 && var.create_cos_bucket) ? [

    # returns a set containing rules and the bucket to which the rules to be applied to
    for pair in setproduct(var.bucket_cbr_rules, toset(local.bucket_name)) : {
      cbr_rule_block = pair[0]
      bucket_name    = pair[1]
    }
  ] : []
}

##############################################################################
# Context Based Restrictions
##############################################################################

module "bucket_cbr_rule" {
  # generates a map of with bucket name as key and bucket rule as object
  for_each = {
    for bucket_rule in local.cbr_rules : bucket_rule.bucket_name => bucket_rule
  }

  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-rule-module?ref=v1.1.4"
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

module "instance_cbr_rule" {
  count            = length(var.instance_cbr_rules)
  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-rule-module?ref=v1.1.4"
  rule_description = var.instance_cbr_rules[count.index].description
  enforcement_mode = var.instance_cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.instance_cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.instance_cbr_rules[count.index].account_id
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
    tags = var.instance_cbr_rules[count.index].tags
  }]
  operations = var.instance_cbr_rules[count.index].operations == null ? [] : var.instance_cbr_rules[count.index].operations
}

resource "null_resource" "deprecation_notice" {
  count = var.service_endpoints != null ? 1 : 0
  triggers = {
    always_refresh = timestamp()
  }
  provisioner "local-exec" {
    command = "echo 'WARNING: The service_endpoints variable has been deprecated for this module and will be removed with the next major release.'"
  }
}
