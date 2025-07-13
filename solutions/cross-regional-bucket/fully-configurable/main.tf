##############################################################################
# Secure cross region Bucket
##############################################################################

locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
}

locals {

  bucket_config = [{
    access_tags                   = var.bucket_access_tags
    bucket_name                   = "${local.prefix}${var.bucket_name}"
    kms_encryption_enabled        = var.kms_encryption_enabled
    add_bucket_name_suffix        = var.add_bucket_name_suffix
    kms_guid                      = local.existing_kms_instance_guid
    kms_key_crn                   = local.kms_key_crn
    skip_iam_authorization_policy = local.create_cross_account_auth_policy || var.skip_cos_kms_iam_auth_policy
    management_endpoint_type      = var.management_endpoint_type_for_bucket
    cross_region_location         = var.cross_region_location
    resource_instance_id          = var.existing_cos_instance_crn
    storage_class                 = var.bucket_storage_class
    force_delete                  = var.force_delete
    hard_quota                    = var.bucket_hard_quota
    expire_filter_prefix          = var.expire_filter_prefix
    archive_filter_prefix         = var.archive_filter_prefix
    object_locking_enabled        = var.enable_object_locking
    object_lock_duration_days     = var.object_lock_duration_days
    object_lock_duration_years    = var.object_lock_duration_years

    activity_tracking = {
      read_data_events  = true
      write_data_events = true
      management_events = true
    }
    expire_rule = var.expire_days != null ? {
      enable = true
      days   = var.expire_days
    } : null
    metrics_monitoring = {
      usage_metrics_enabled   = true
      request_metrics_enabled = true
      metrics_monitoring_crn  = var.monitoring_crn
    }
    object_versioning = {
      enable = var.enable_object_versioning
    }
    retention_rule = var.enable_retention ? {
      default   = var.default_retention_days
      maximum   = var.maximum_retention_days
      minimum   = var.minimum_retention_days
      permanent = var.enable_permanent_retention
    } : null

    cos_bucket_cbr_rules = var.cos_bucket_cbr_rules
  }]
}

#######################################################################################################################
# Parse COS
#######################################################################################################################

module "cos_instance_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_cos_instance_crn
}

locals {
  cos_instance_guid = module.cos_instance_crn_parser.service_instance
}

#######################################################################################################################
# KMS Key
#######################################################################################################################

locals {
  existing_kms_instance_guid = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].service_instance : var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].service_instance : null : null
  kms_region                 = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].region : var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].region : null : null
  kms_service_name           = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].service_name : var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].service_name : null : null
  kms_account_id             = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? module.kms_instance_crn_parser[0].account_id : var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].account_id : null : null

  kms_key_crn = var.kms_encryption_enabled ? var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", var.cos_key_ring_name, var.cos_key_name)].crn : null

  kms_key_id = var.kms_encryption_enabled ? var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].resource : module.kms[0].keys[format("%s.%s", var.cos_key_ring_name, var.cos_key_name)].key_id : null

  create_cross_account_auth_policy = !var.skip_cos_kms_iam_auth_policy && var.ibmcloud_kms_api_key != null
}

########################################################################################################################
# Parse KMS info from given CRNs
########################################################################################################################

module "kms_instance_crn_parser" {
  count   = var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_kms_instance_crn
}

module "kms_key_crn_parser" {
  count   = var.existing_kms_key_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_kms_key_crn
}

# Create IAM Authorization Policy to allow COS to access KMS for the encryption key
resource "ibm_iam_authorization_policy" "cos_kms_policy" {
  count                       = local.create_cross_account_auth_policy ? 1 : 0
  provider                    = ibm.kms
  source_service_account      = module.cos_instance_crn_parser.account_id
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow the COS instance ${local.cos_instance_guid} to read the ${local.kms_service_name} key ${local.kms_key_id} from the instance ${local.existing_kms_instance_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service_name
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.existing_kms_instance_guid
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

resource "time_sleep" "wait_for_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.cos_kms_policy]
  create_duration = "30s"
}

# KMS root key for COS cross region bucket
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = var.kms_encryption_enabled && var.existing_kms_key_crn != null ? 0 : 1 # no need to create any KMS resources if passing an existing key.
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "5.1.10"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name     = var.cos_key_ring_name
      existing_key_ring = false
      keys = [
        {
          key_name                 = var.cos_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}

#######################################################################################################################
# COS Bucket
#######################################################################################################################

module "cos" {
  providers = {
    ibm = ibm.cos
  }
  depends_on     = [time_sleep.wait_for_authorization_policy]
  source         = "../../../modules/buckets"
  bucket_configs = local.bucket_config
}
