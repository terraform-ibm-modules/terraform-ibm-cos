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
  validate_bucket_inputs = var.create_cos_bucket && var.bucket_name == null ? tobool("If var.create_cos_bucket is true, then provide value for var.bucket_name") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cos_inputs = var.create_cos_instance && var.cos_instance_name == null ? tobool("If var.create_cos_instance is true, then provide value for var.cos_instance_name") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cos_id_input = !var.create_cos_instance && var.existing_cos_instance_id == null ? tobool("If var.create_cos_instance is false, then provide a value for var.existing_cos_instance_id to create buckets") : true
  # tflint-ignore: terraform_unused_declarations
  validate_kp_guid_input = var.encryption_enabled && var.create_cos_instance && var.existing_key_protect_instance_guid == null ? tobool("A value must be passed for var.existing_key_protect_instance_guid when var.create_cos_instance and var.encryption_enabled is true.") : true
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
  service_endpoints = var.service_endpoints
}

locals {
  cos_instance_id      = var.create_cos_instance == true ? tolist(ibm_resource_instance.cos_instance[*].id)[0] : var.existing_cos_instance_id
  create_access_policy = var.encryption_enabled && var.create_cos_instance
}

# Create IAM Access Policy to allow Key protect to access COS instance
resource "ibm_iam_authorization_policy" "policy" {
  count                       = local.create_access_policy ? 1 : 0
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_id
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
  count                = (var.encryption_enabled && var.create_cos_bucket) ? 1 : 0
  depends_on           = [ibm_iam_authorization_policy.policy]
  bucket_name          = var.bucket_name
  resource_instance_id = local.cos_instance_id
  region_location      = var.region
  storage_class        = "standard"
  key_protect          = var.key_protect_key_crn
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
  dynamic "object_versioning" {
    for_each = local.object_versioning_enabled
    content {
      enable = var.object_versioning_enabled
    }
  }
}

# Create COS bucket with:
# - Retention
# - Encryption
# - Monitoring
# - Activity Tracking
# Create COS bucket without:
# - Encryption

resource "ibm_cos_bucket" "cos_bucket1" {
  count                = (!var.encryption_enabled && var.create_cos_bucket) ? 1 : 0
  bucket_name          = var.bucket_name
  resource_instance_id = local.cos_instance_id
  region_location      = var.region
  storage_class        = "standard"
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
}

locals {
  bucket_id           = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].id : ibm_cos_bucket.cos_bucket1[*].id
  bucket_name         = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].bucket_name : ibm_cos_bucket.cos_bucket1[*].bucket_name
  s3_endpoint_public  = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].s3_endpoint_public : ibm_cos_bucket.cos_bucket1[*].s3_endpoint_public
  s3_endpoint_private = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*].s3_endpoint_private : ibm_cos_bucket.cos_bucket1[*].s3_endpoint_private
}
