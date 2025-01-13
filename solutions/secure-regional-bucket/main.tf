##############################################################################
# Secure Regional Bucket
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_inputs = var.existing_kms_key_crn == null && var.existing_kms_instance_crn == null ? tobool("A value must be passed for 'existing_kms_instance_crn' if not supplying any value for 'existing_kms_key_crn'.") : true

  existing_kms_instance_guid       = var.existing_kms_instance_crn != null ? element(split(":", var.existing_kms_instance_crn), length(split(":", var.existing_kms_instance_crn)) - 3) : null
  existing_kms_instance_region     = var.existing_kms_instance_crn != null ? element(split(":", var.existing_kms_instance_crn), length(split(":", var.existing_kms_instance_crn)) - 5) : null
  cos_instance_guid                = var.existing_cos_instance_id != null ? element(split(":", var.existing_cos_instance_id), length(split(":", var.existing_cos_instance_id)) - 3) : null
  create_cross_account_auth_policy = !var.skip_iam_authorization_policy && var.ibmcloud_kms_api_key != null

  kms_service_name = var.existing_kms_instance_crn != null ? (
    can(regex(".*kms.*", var.existing_kms_instance_crn)) ? "kms" : (
      can(regex(".*hs-crypto.*", var.existing_kms_instance_crn)) ? "hs-crypto" : null
    )
  ) : null
  kms_account_id = var.existing_kms_instance_crn != null ? split("/", coalescelist(split(":", var.existing_kms_instance_crn))[6])[1] : null
  kms_key_crn    = var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", var.key_ring_name, var.key_name)].crn
  kms_key_id     = coalescelist(split(":", local.kms_key_crn))[9]

  bucket_config = [{
    access_tags                   = var.bucket_access_tags
    bucket_name                   = var.bucket_name
    kms_encryption_enabled        = true
    add_bucket_name_suffix        = var.add_bucket_name_suffix
    kms_guid                      = local.existing_kms_instance_guid
    kms_key_crn                   = local.kms_key_crn
    skip_iam_authorization_policy = local.create_cross_account_auth_policy || var.skip_iam_authorization_policy
    management_endpoint_type      = var.management_endpoint_type_for_bucket
    region_location               = var.region
    storage_class                 = var.bucket_storage_class
    force_delete                  = var.force_delete
    hard_quota                    = var.hard_quota
    expire_filter_prefix          = var.expire_filter_prefix
    archive_filter_prefix         = var.archive_filter_prefix
    object_locking_enabled        = var.object_locking_enabled
    object_lock_duration_days     = var.object_lock_duration_days
    object_lock_duration_years    = var.object_lock_duration_years

    activity_tracking = {
      read_data_events  = true
      write_data_events = true
    }
    archive_rule = var.archive_days != null ? {
      enable = true
      days   = var.archive_days
      type   = var.archive_type
    } : null
    expire_rule = var.expire_days != null ? {
      enable = true
      days   = var.expire_days
    } : null
    metrics_monitoring = {
      usage_metrics_enabled   = true
      request_metrics_enabled = true
      management_events       = true
      metrics_monitoring_crn  = var.monitoring_crn
    }
    object_versioning = {
      enable = var.object_versioning_enabled
    }
    retention_rule = var.retention_enabled ? {
      default   = var.retention_default
      maximum   = var.retention_maximum
      minimum   = var.retention_minimum
      permanent = var.retention_permanent
    } : null
  }]
}

#######################################################################################################################
# KMS Key
#######################################################################################################################
module "cos_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_cos_instance_id
}

# Create IAM Authorization Policy to allow COS to access KMS for the encryption key
resource "ibm_iam_authorization_policy" "cos_kms_policy" {
  count                       = local.create_cross_account_auth_policy ? 1 : 0
  provider                    = ibm.kms
  source_service_account      = module.cos_crn_parser.account_id
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

# KMS root key for COS bucket
module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = var.existing_kms_key_crn != null ? 0 : 1 # no need to create any KMS resources if passing an existing key
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.19.2"
  create_key_protect_instance = false
  region                      = local.existing_kms_instance_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name     = var.key_ring_name
      existing_key_ring = false
      keys = [
        {
          key_name                 = var.key_name
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
  depends_on               = [time_sleep.wait_for_authorization_policy]
  source                   = "../../modules/fscloud"
  resource_group_id        = null
  create_cos_instance      = false
  existing_cos_instance_id = var.existing_cos_instance_id
  bucket_configs           = local.bucket_config
  instance_cbr_rules       = var.instance_cbr_rules
}
