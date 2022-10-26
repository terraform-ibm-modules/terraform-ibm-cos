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
  infix                     = var.bucket_infix == null ? "" : "-${var.bucket_infix}"

  #ensure if create_cos_instance = false, then cos_instance_name is provided
  cos_validate_condition = (!var.create_cos_instance && var.cos_instance_name == null)
  cos_validate_msg       = "If create_cos_instance is false, then provide the cos_instance_name to create buckets"
  # tflint-ignore: terraform_unused_declarations
  cos_validate_check = regex("^${local.cos_validate_msg}$", (!local.cos_validate_condition ? local.cos_validate_msg : ""))

}

locals {
  key_crn = var.encryption_enabled ? var.key_protect_key_crn : ""
}

# Resource to create COS instance if create_cos_instance is true
resource "ibm_resource_instance" "cos_instance" {
  count             = var.create_cos_instance ? 1 : 0
  name              = "${var.environment_name}-cos"
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = var.cos_location
}

locals {
  cos_instance_id      = var.create_cos_instance == true ? ibm_resource_instance.cos_instance.*.id[0] : data.ibm_resource_instance.cos_instance.*.id[0]
  cos_instance_guid    = var.create_cos_instance == true ? ibm_resource_instance.cos_instance.*.guid[0] : data.ibm_resource_instance.cos_instance.*.guid[0]
  create_access_policy = var.encryption_enabled
}

# Data source to retrieve COS instance guid if using an existing COS instance
data "ibm_resource_instance" "cos_instance" {
  count             = var.create_cos_instance ? 0 : 1
  name              = var.cos_instance_name
  location          = var.cos_location
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
}

# Data source to retrieve the key protect guid
data "ibm_resource_instance" "keyprotect_instance" {
  count = var.key_protect_instance_name == null ? 0 : 1
  name  = var.key_protect_instance_name
}

# Create IAM Access Policy to allow Key protect to access COS instance
resource "ibm_iam_authorization_policy" "policy" {
  count                       = local.create_access_policy ? 1 : 0
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  target_service_name         = "kms"
  target_resource_instance_id = data.ibm_resource_instance.keyprotect_instance[0].guid
  roles                       = ["Reader"]
}

# Create COS bucket
resource "ibm_cos_bucket" "cos_bucket" {
  count                = var.encryption_enabled ? 1 : 0
  depends_on           = [ibm_iam_authorization_policy.policy]
  bucket_name          = "${var.environment_name}${local.infix}-bucket-${var.region}"
  resource_instance_id = local.cos_instance_id
  region_location      = var.region
  storage_class        = "standard"
  key_protect          = local.key_crn
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
  count                = var.encryption_enabled ? 0 : 1
  bucket_name          = "${var.environment_name}${local.infix}-bucket-${var.region}"
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
  bucket_id           = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket.*.id : ibm_cos_bucket.cos_bucket1.*.id
  bucket_name         = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket.*.bucket_name : ibm_cos_bucket.cos_bucket1.*.bucket_name
  s3_endpoint_public  = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket.*.s3_endpoint_public : ibm_cos_bucket.cos_bucket1.*.s3_endpoint_public
  s3_endpoint_private = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket.*.s3_endpoint_private : ibm_cos_bucket.cos_bucket1.*.s3_endpoint_private
}
