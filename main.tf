##############################################################################
# terraform-ibm-cos
#
# Creates COS instance and buckets
##############################################################################

locals {
  at_enabled                 = var.activity_tracker_read_data_events || var.activity_tracker_write_data_events ? [1] : []
  metrics_enabled            = var.request_metrics_enabled || var.usage_metrics_enabled ? [1] : []
  archive_enabled            = var.archive_days == null ? [] : [1]
  expire_enabled             = var.expire_days == null ? [] : [1]
  retention_enabled          = var.retention_enabled ? [1] : []
  object_lock_duration_days  = var.object_lock_duration_days > 0 ? [1] : []
  object_lock_duration_years = var.object_lock_duration_years > 0 ? [1] : []
  object_versioning_enabled  = var.object_versioning_enabled ? [1] : []

  # input variable validation
  # tflint-ignore: terraform_unused_declarations
  validate_encryption_inputs = !var.create_cos_instance && !var.create_cos_bucket ? tobool("var.create_cos_instance and var.create_cos_bucket cannot be both set to false") : true
  # tflint-ignore: terraform_unused_declarations
  validate_key_inputs = var.create_cos_bucket && var.kms_encryption_enabled && var.kms_key_crn == null ? tobool("A value must be passed for var.kms_key_crn when both var.create_cos_bucket and var.kms_encryption_enabled are true") : true
  # tflint-ignore: terraform_unused_declarations
  validate_bucket_inputs = var.create_cos_bucket && var.bucket_name == null ? tobool("If var.create_cos_bucket is true, then provide value for var.bucket_name") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cos_inputs = var.create_cos_instance && var.cos_instance_name == null ? tobool("If var.create_cos_instance is true, then provide value for var.cos_instance_name") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cos_id_input = !var.create_cos_instance && var.existing_cos_instance_id == null ? tobool("If var.create_cos_instance is false, then provide a value for var.existing_cos_instance_id to create buckets") : true
  # tflint-ignore: terraform_unused_declarations
  validate_resource_group_id_input = var.create_cos_instance && var.resource_group_id == null ? tobool("If var.create_cos_instance is true, then provide a value for var.resource_group_id to create COS instance") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cross_region_and_plan_input = var.cross_region_location != null && var.cos_plan == "cos-one-rate-plan" ? tobool("var.cos_plan is 'cos-one-rate-plan', then var.cross_region_location cannot be set as the one rate plan does not support cross region.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_create_cos_instance_with_existing_id = var.create_cos_instance && var.existing_cos_instance_id != null ? tobool("create_cos_instance cannot be true when existing_cos_instance_id is provided.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_kp_guid_input = var.kms_encryption_enabled && var.create_cos_bucket && var.skip_iam_authorization_policy == false && var.existing_kms_instance_guid == null ? tobool("A value must be passed for var.existing_kms_instance_guid when creating a bucket when var.kms_encryption_enabled is true and var.skip_iam_authorization_policy is false.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cross_region_location_inputs = var.create_cos_bucket && ((var.cross_region_location == null && var.region == null && var.single_site_location == null) || (var.cross_region_location != null && var.region != null && var.single_site_location != null) || (var.cross_region_location != null && var.region != null) || (var.region != null && var.single_site_location != null) || (var.cross_region_location != null && var.single_site_location != null)) ? tobool("If var.create_cos_bucket is true, then value needs to be provided for var.cross_region_location or var.region or var.single_site_location, only one of the regions can be set.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cross_region_location_archive_disabled_inputs = var.create_cos_bucket && (var.cross_region_location != null && var.archive_days != null) ? tobool("If var.cross_region_location is set, then var.archive_days cannot be set.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_single_site_location_inputs = var.single_site_location != null && var.kms_encryption_enabled == true ? tobool("If var.single_site_location is set, then var.kms_encryption_enabled cannot be set as the key protect does not support single site location.") : true
  # retention/immuatbile object storage https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-availability#service-availability
  # only in cross region 'us' and all mzr
  # tflint-ignore: terraform_unused_declarations
  validate_cross_region_retention = var.cross_region_location != null && (var.cross_region_location != "us" && var.retention_enabled) ? tobool("Retention is currently only supported in the `US` location for cross region buckets.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_cross_region_kms = var.cross_region_location != "us" && var.cross_region_location != null ? can(regex(".*hs-crypto.*", var.kms_key_crn)) ? tobool("Support for using HPCS instance for KMS encryption in cross-regional bucket is only available in US region.") : true : true
  # tflint-ignore: terraform_unused_declarations
  validate_locking = var.object_locking_enabled && !var.object_versioning_enabled ? tobool("Object locking requires object versioning to be enabled.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_lock_duration_both = var.object_locking_enabled && var.object_lock_duration_days != 0 && var.object_lock_duration_years != 0 ? tobool("Object lock duration days and years can not both be set.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_lock_duration_none = var.object_locking_enabled && var.object_lock_duration_days == 0 && var.object_lock_duration_years == 0 ? tobool("Object lock duration days or years must be set.") : true
}

resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.policy]
  count      = local.create_access_policy_kms ? 1 : 0
  # workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
  create_duration = "30s"
  # workaround for https://github.com/terraform-ibm-modules/terraform-ibm-cos/issues/672
  destroy_duration = "30s"
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

resource "ibm_resource_tag" "cos_access_tag" {
  count       = !var.create_cos_instance || length(var.access_tags) == 0 ? 0 : 1
  resource_id = ibm_resource_instance.cos_instance[0].crn
  tags        = var.access_tags
  tag_type    = "access"
}

resource "ibm_resource_key" "resource_keys" {
  for_each             = { for key in var.resource_keys : key.name => key }
  name                 = each.value.key_name == null ? each.key : each.value.key_name
  resource_instance_id = local.cos_instance_id
  role                 = each.value.role
  parameters = {
    "serviceid_crn" = each.value.service_id_crn
    "HMAC"          = each.value.generate_hmac_credentials
  }
}

locals {
  cos_instance_id          = var.create_cos_instance ? ibm_resource_instance.cos_instance[0].id : var.existing_cos_instance_id
  cos_instance_guid        = var.create_cos_instance ? ibm_resource_instance.cos_instance[0].guid : element(split(":", var.existing_cos_instance_id), length(split(":", var.existing_cos_instance_id)) - 3)
  cos_instance_name        = var.create_cos_instance ? ibm_resource_instance.cos_instance[0].name : null
  cos_instance_crn         = var.create_cos_instance ? ibm_resource_instance.cos_instance[0].crn : null
  create_access_policy_kms = var.kms_encryption_enabled && var.create_cos_bucket && !var.skip_iam_authorization_policy
  parsed_kms_key_crn       = var.kms_key_crn != null ? split(":", var.kms_key_crn) : []
  kms_service              = length(local.parsed_kms_key_crn) > 0 ? local.parsed_kms_key_crn[4] : null
  kms_scope                = length(local.parsed_kms_key_crn) > 0 ? local.parsed_kms_key_crn[6] : null
  kms_account_id           = length(local.parsed_kms_key_crn) > 0 ? split("/", local.kms_scope)[1] : null
  kms_key_id               = length(local.parsed_kms_key_crn) > 0 ? local.parsed_kms_key_crn[9] : null
}

# Create IAM Authorization Policy to allow COS to access KMS for the encryption key
resource "ibm_iam_authorization_policy" "policy" {
  count                       = local.create_access_policy_kms ? 1 : 0
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow the COS instance ${local.cos_instance_guid} to read the ${local.kms_service} key ${local.kms_key_id} from the instance ${var.existing_kms_instance_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = var.existing_kms_instance_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_id
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
}

# Create random string which is added to COS bucket name as a suffix
resource "random_string" "bucket_name_suffix" {
  count   = var.add_bucket_name_suffix ? 1 : 0
  length  = 4
  special = false
  upper   = false
}

# Create COS bucket with:
# - Retention
# - Encryption
# - Monitoring
# - Activity Tracking
# - Versioning
resource "ibm_cos_bucket" "cos_bucket" {
  count                 = (var.kms_encryption_enabled && var.create_cos_bucket) ? 1 : 0
  depends_on            = [time_sleep.wait_for_authorization_policy]
  bucket_name           = var.add_bucket_name_suffix ? "${var.bucket_name}-${random_string.bucket_name_suffix[0].result}" : var.bucket_name
  resource_instance_id  = local.cos_instance_id
  region_location       = var.region
  cross_region_location = var.cross_region_location
  single_site_location  = var.single_site_location
  endpoint_type         = var.management_endpoint_type_for_bucket
  storage_class         = var.bucket_storage_class
  key_protect           = var.kms_key_crn
  hard_quota            = var.hard_quota
  force_delete          = var.force_delete
  object_lock           = var.object_locking_enabled ? true : null
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
  ## This for_each block is NOT a loop to attach to multiple Activity Tracker instances.
  ## This block is only used to conditionally attach activity tracker depending on AT CRN is provided.
  dynamic "activity_tracking" {
    for_each = local.at_enabled
    content {
      read_data_events  = var.activity_tracker_read_data_events
      write_data_events = var.activity_tracker_write_data_events
      management_events = var.activity_tracker_management_events
    }
  }
  ## This for_each block is NOT a loop to attach to multiple Sysdig instances.
  ## This block is only used to conditionally attach monitoring depending on Sydig CRN is provided.
  dynamic "metrics_monitoring" {
    for_each = local.metrics_enabled
    content {
      usage_metrics_enabled   = var.usage_metrics_enabled
      request_metrics_enabled = var.request_metrics_enabled
      metrics_monitoring_crn  = var.monitoring_crn
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
# - Monitoring
# - Activity Tracking
# - Versioning
# Create COS bucket without:
# - Encryption
resource "ibm_cos_bucket" "cos_bucket1" {
  count                 = (!var.kms_encryption_enabled && var.create_cos_bucket) ? 1 : 0
  bucket_name           = var.add_bucket_name_suffix ? "${var.bucket_name}-${random_string.bucket_name_suffix[0].result}" : var.bucket_name
  depends_on            = [time_sleep.wait_for_authorization_policy]
  resource_instance_id  = local.cos_instance_id
  region_location       = var.region
  cross_region_location = var.cross_region_location
  single_site_location  = var.single_site_location
  endpoint_type         = var.management_endpoint_type_for_bucket
  storage_class         = var.bucket_storage_class
  hard_quota            = var.hard_quota
  force_delete          = var.force_delete
  object_lock           = var.object_locking_enabled ? true : null
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
  ## This for_each block is NOT a loop to attach to multiple Activity Tracker instances.
  ## This block is only used to conditionally attach activity tracker depending on AT CRN is provided.
  dynamic "activity_tracking" {
    for_each = local.at_enabled
    content {
      read_data_events  = var.activity_tracker_read_data_events
      write_data_events = var.activity_tracker_write_data_events
      management_events = var.activity_tracker_management_events
    }
  }
  ## This for_each block is NOT a loop to attach to multiple Sysdig instances.
  ## This block is only used to conditionally attach monitoring depending on Sydig CRN is provided.
  dynamic "metrics_monitoring" {
    for_each = local.metrics_enabled
    content {
      usage_metrics_enabled   = var.usage_metrics_enabled
      request_metrics_enabled = var.request_metrics_enabled
      metrics_monitoring_crn  = var.monitoring_crn
    }
  }
  dynamic "object_versioning" {
    for_each = local.object_versioning_enabled
    content {
      enable = var.object_versioning_enabled
    }
  }
}

locals {
  create_cos_bucket  = (var.kms_encryption_enabled && var.create_cos_bucket) ? true : false
  create_cos_bucket1 = (!var.kms_encryption_enabled && var.create_cos_bucket) ? true : false

  cos_bucket_resource = local.create_cos_bucket ? ibm_cos_bucket.cos_bucket : local.create_cos_bucket1 ? ibm_cos_bucket.cos_bucket1 : null
}

resource "ibm_cos_bucket_lifecycle_configuration" "cos_bucket_lifecycle" {
  count = local.create_cos_bucket || local.create_cos_bucket1 ? 1 : 0

  bucket_crn      = local.cos_bucket_resource[count.index].crn
  bucket_location = local.cos_bucket_resource[count.index].region_location

  dynamic "lifecycle_rule" {
    ## This for_each block is NOT a loop to attach to multiple expiration blocks.
    ## This block is only used to conditionally add expiration block depending on expire rule is enabled.
    for_each = local.expire_enabled
    content {
      expiration {
        days = var.expire_days
      }
      filter {
        prefix = ""
      }
      rule_id = "expiry-rule"
      status  = "enable"
    }
  }
  dynamic "lifecycle_rule" {
    ## This for_each block is NOT a loop to attach to multiple transition blocks.
    ## This block is only used to conditionally add retention block depending on archive rule is enabled.
    for_each = local.archive_enabled
    content {
      transition {
        days          = var.archive_days
        storage_class = upper(var.archive_type)

      }
      filter {
        prefix = ""
      }
      rule_id = "archive-rule"
      status  = "enable"
    }
  }
}

locals {
  bucket_crn           = var.create_cos_bucket ? (var.kms_encryption_enabled ? ibm_cos_bucket.cos_bucket[0].crn : ibm_cos_bucket.cos_bucket1[0].crn) : null
  bucket_id            = var.create_cos_bucket ? (var.kms_encryption_enabled ? ibm_cos_bucket.cos_bucket[0].id : ibm_cos_bucket.cos_bucket1[0].id) : null
  bucket_region        = var.create_cos_bucket ? (var.kms_encryption_enabled ? ibm_cos_bucket.cos_bucket[0].region_location : ibm_cos_bucket.cos_bucket1[0].region_location) : null
  bucket_name          = var.create_cos_bucket ? (var.kms_encryption_enabled ? ibm_cos_bucket.cos_bucket[0].bucket_name : ibm_cos_bucket.cos_bucket1[0].bucket_name) : null
  bucket_storage_class = var.create_cos_bucket ? (var.kms_encryption_enabled ? ibm_cos_bucket.cos_bucket[0].storage_class : ibm_cos_bucket.cos_bucket1[0].storage_class) : null
  s3_endpoint_public   = var.create_cos_bucket ? (var.kms_encryption_enabled ? ibm_cos_bucket.cos_bucket[0].s3_endpoint_public : ibm_cos_bucket.cos_bucket1[0].s3_endpoint_public) : null
  s3_endpoint_private  = var.create_cos_bucket ? (var.kms_encryption_enabled ? ibm_cos_bucket.cos_bucket[0].s3_endpoint_private : ibm_cos_bucket.cos_bucket1[0].s3_endpoint_private) : null
  s3_endpoint_direct   = var.create_cos_bucket ? (var.kms_encryption_enabled ? ibm_cos_bucket.cos_bucket[0].s3_endpoint_direct : ibm_cos_bucket.cos_bucket1[0].s3_endpoint_direct) : null
}

##############################################################################
# Bucket retention lock
##############################################################################

resource "ibm_cos_bucket_object_lock_configuration" "lock_configuration" {
  count           = var.object_locking_enabled ? 1 : 0
  bucket_crn      = local.bucket_crn
  bucket_location = local.bucket_region
  endpoint_type   = var.management_endpoint_type_for_bucket

  # This is not a loop. Include either the `days` or `years`.
  dynamic "object_lock_configuration" {
    for_each = local.object_lock_duration_days
    content {
      object_lock_enabled = "Enabled" # only accepts "Enabled"
      object_lock_rule {
        default_retention {
          mode = "COMPLIANCE" # only accepts "COMPLIANCE"
          days = var.object_lock_duration_days
        }
      }
    }
  }
  # This is not a loop. Include either the `days` or `years`.
  dynamic "object_lock_configuration" {
    for_each = local.object_lock_duration_years
    content {
      object_lock_enabled = "Enabled" # only accepts "Enabled"
      object_lock_rule {
        default_retention {
          mode  = "COMPLIANCE" # only accepts "COMPLIANCE"
          years = var.object_lock_duration_years
        }
      }
    }
  }
}

##############################################################################
# Context Based Restrictions
##############################################################################

locals {
  default_operations = [{
    api_types = [{
      api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
    }]
  }]
}

module "bucket_cbr_rule" {
  count            = (length(var.bucket_cbr_rules) > 0 && var.create_cos_bucket) ? length(var.bucket_cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.28.1"
  rule_description = var.bucket_cbr_rules[count.index].description
  enforcement_mode = var.bucket_cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.bucket_cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.bucket_cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "resource"
        value    = local.bucket_name
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
    tags = var.bucket_cbr_rules[count.index].tags
  }]
  operations = var.bucket_cbr_rules[count.index].operations == null ? local.default_operations : var.bucket_cbr_rules[count.index].operations
}

module "instance_cbr_rule" {
  count            = length(var.instance_cbr_rules)
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.28.1"
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
  operations = var.instance_cbr_rules[count.index].operations == null ? local.default_operations : var.instance_cbr_rules[count.index].operations
}

locals {
  bucket_rule_ids   = [for instance in module.bucket_cbr_rule : instance.rule_id]
  instance_rule_ids = flatten([for instance in module.instance_cbr_rule : instance.rule_id])
  all_rule_ids      = concat(local.bucket_rule_ids, local.instance_rule_ids)
}
