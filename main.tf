##############################################################################
# COS instance configuration
##############################################################################

# Instance creation
resource "ibm_resource_instance" "cos_instance" {
  count             = var.create_cos_instance ? 1 : 0
  name              = var.cos_instance_name
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = "global"
  tags              = var.cos_tags
}

# Instance access tags
data "ibm_iam_access_tag" "access_tag" {
  for_each = length(var.access_tags) != 0 ? toset(var.access_tags) : []
  name     = each.value
}

resource "ibm_resource_tag" "cos_access_tag" {
  depends_on  = [data.ibm_iam_access_tag.access_tag]
  count       = !var.create_cos_instance || length(var.access_tags) == 0 ? 0 : 1
  resource_id = ibm_resource_instance.cos_instance[0].crn
  tags        = var.access_tags
  tag_type    = "access"
}

# Instance resource keys
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

# Lookup instance details
data "ibm_resource_instance" "cos_instance" {
  identifier = var.create_cos_instance ? ibm_resource_instance.cos_instance[0].id : var.existing_cos_instance_id
}

# Parse the CRN to get the account ID (above data lookup does not output account ID)
module "cos_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.4.2"
  crn     = local.cos_instance_crn
}

# Instance locals
locals {
  cos_instance_id   = data.ibm_resource_instance.cos_instance.id
  cos_instance_guid = data.ibm_resource_instance.cos_instance.guid
  cos_instance_name = data.ibm_resource_instance.cos_instance.name
  cos_instance_crn  = data.ibm_resource_instance.cos_instance.crn
  cos_account_id    = module.cos_crn_parser.account_id
}

##############################################################################
# COS bucket
##############################################################################

# Bucket locals
locals {
  at_enabled                            = var.activity_tracker_read_data_events || var.activity_tracker_write_data_events ? [1] : []
  metrics_enabled                       = var.request_metrics_enabled || var.usage_metrics_enabled ? [1] : []
  archive_enabled                       = var.archive_days == null ? [] : [1]
  expire_enabled                        = var.expire_days == null ? [] : [1]
  noncurrent_version_expiration_enabled = var.noncurrent_version_expiration_days == null ? [] : [1]
  abort_multipart_enabled               = var.abort_multipart_days == null ? [] : [1]
  retention_enabled                     = var.retention_enabled ? [1] : []
  object_lock_duration_days             = var.object_lock_duration_days > 0 ? [1] : []
  object_lock_duration_years            = var.object_lock_duration_years > 0 ? [1] : []
  object_versioning_enabled             = var.object_versioning_enabled ? [1] : []
  create_access_policy_kms              = var.kms_encryption_enabled && var.create_cos_bucket && !var.skip_iam_authorization_policy
}

# If KMS encryption enabled, parse details from the KMS key CRN
module "kms_crn_parser" {
  count   = local.create_access_policy_kms ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.4.2"
  crn     = var.kms_key_crn
}
locals {
  kms_key_id        = local.create_access_policy_kms ? module.kms_crn_parser[0].resource : ""
  kms_instance_guid = local.create_access_policy_kms ? module.kms_crn_parser[0].service_instance : ""
  kms_service       = local.create_access_policy_kms ? module.kms_crn_parser[0].service_name : ""
  kms_account_id    = local.create_access_policy_kms ? module.kms_crn_parser[0].account_id : ""
}

# If KMS encryption enabled, create required IAM auth policy to allow COS to read the root key
resource "ibm_iam_authorization_policy" "policy" {
  count                       = local.create_access_policy_kms ? 1 : 0
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow the COS instance ${local.cos_instance_guid} to read the ${local.kms_service} key ${local.kms_key_id} from the instance ${local.kms_instance_guid}"
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
    value    = local.kms_instance_guid
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
  depends_on = [ibm_iam_authorization_policy.policy]
  count      = local.create_access_policy_kms ? 1 : 0
  # workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
  create_duration = "30s"
  # workaround for https://github.com/terraform-ibm-modules/terraform-ibm-cos/issues/672
  destroy_duration = "30s"
}

# Create random string which is added to COS bucket name as a suffix
resource "random_string" "bucket_name_suffix" {
  count   = var.add_bucket_name_suffix && var.create_cos_bucket ? 1 : 0
  length  = 4
  special = false
  upper   = false
}

locals {
  random_bucket_name_suffix = var.add_bucket_name_suffix && var.create_cos_bucket ? random_string.bucket_name_suffix[0].result : null
}

resource "ibm_cos_bucket" "cos_bucket" {
  count                 = var.create_cos_bucket ? 1 : 0
  depends_on            = [time_sleep.wait_for_authorization_policy]
  bucket_name           = var.add_bucket_name_suffix ? "${var.bucket_name}-${local.random_bucket_name_suffix}" : var.bucket_name
  resource_instance_id  = local.cos_instance_id
  region_location       = var.region
  cross_region_location = var.cross_region_location
  single_site_location  = var.single_site_location
  endpoint_type         = var.management_endpoint_type_for_bucket
  storage_class         = var.bucket_storage_class
  # NOTE: The provider changed this input from key_protect -> kms_key_crn however we cannot change here as it will be a breaking change.
  # The provider will continue to support key_protect to prevent existing consumers from breaking.
  key_protect  = var.kms_encryption_enabled ? var.kms_key_crn : null
  hard_quota   = var.hard_quota
  force_delete = var.force_delete
  object_lock  = var.object_locking_enabled ? true : null
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
  create_access_policy = var.create_cos_bucket && var.allow_public_access_to_bucket ? 1 : 0
}

# use a data lookup to get the ID of the "Public Access" IAM access group
data "ibm_iam_access_group" "public_access_group" {
  count             = local.create_access_policy
  access_group_name = "Public Access"
}

# create an IAM access policy to granting public access to cos bucket
resource "ibm_iam_access_group_policy" "access_policy" {
  count           = local.create_access_policy
  access_group_id = data.ibm_iam_access_group.public_access_group[0].groups[0].id
  roles           = var.public_access_role

  resources {
    service              = "cloud-object-storage"
    resource_type        = "bucket"
    resource_instance_id = local.cos_instance_guid
    resource             = local.bucket_name
  }
}

locals {
  expiration_or_archiving_or_noncurrent_version_expiration_rule_enabled = (length(local.expire_enabled) != 0 || length(local.archive_enabled) != 0 || length(local.noncurrent_version_expiration_enabled) != 0 || length(local.abort_multipart_enabled) != 0)

  ## Only one of these values can be set, leaving 2 of 3 null, compact function removes nulls.
  ## We then take the only value left in the list
  cos_region = compact([var.region, var.cross_region_location, var.single_site_location])[0]
}

resource "ibm_cos_bucket_lifecycle_configuration" "cos_bucket_lifecycle" {
  count = var.create_cos_bucket && local.expiration_or_archiving_or_noncurrent_version_expiration_rule_enabled ? 1 : 0

  bucket_crn      = ibm_cos_bucket.cos_bucket[count.index].crn
  bucket_location = local.cos_region
  endpoint_type   = var.management_endpoint_type_for_bucket

  dynamic "lifecycle_rule" {
    ## This for_each block is NOT a loop to attach to multiple expiration blocks.
    ## This block is only used to conditionally add expiration block depending on expire rule is enabled.
    for_each = local.expire_enabled
    content {
      expiration {
        days = var.expire_days
      }
      filter {
        prefix = var.expire_filter_prefix != null ? var.expire_filter_prefix : ""
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
        days = var.archive_days
        ## The new values changed from Capatalized to all Upper case, avoid having to change values in new release
        storage_class = upper(var.archive_type)

      }
      filter {
        prefix = var.archive_filter_prefix != null ? var.archive_filter_prefix : ""
      }
      rule_id = "archive-rule"
      status  = "enable"
    }
  }

  dynamic "lifecycle_rule" {
    ## This for_each block is NOT a loop to attach to multiple noncurrent version expiration blocks.
    ## This block is only used to conditionally add noncurrent version expiration block depending on noncurrent version expiration rule is enabled.
    for_each = local.noncurrent_version_expiration_enabled
    content {
      noncurrent_version_expiration {
        noncurrent_days = var.noncurrent_version_expiration_days
      }
      filter {
        prefix = var.noncurrent_version_expiration_filter_prefix != null ? var.noncurrent_version_expiration_filter_prefix : ""
      }
      rule_id = "noncurrent-version-expiry-rule"
      status  = "enable"
    }
  }

  dynamic "lifecycle_rule" {
    ## This for_each block is NOT a loop to attach to multiple abort multipart blocks.
    ## This block is only used to conditionally add abort multipart upload depending on abort multipart enabled rule is enabled.
    for_each = local.abort_multipart_enabled
    content {
      abort_incomplete_multipart_upload {
        days_after_initiation = var.abort_multipart_days
      }
      filter {
        prefix = var.abort_multipart_filter_prefix != null ? var.abort_multipart_filter_prefix : ""
      }
      rule_id = "abort-multipart-rule"
      status  = "enable"
    }
  }
}

locals {
  bucket_crn           = var.create_cos_bucket ? ibm_cos_bucket.cos_bucket[0].crn : null
  bucket_id            = var.create_cos_bucket ? ibm_cos_bucket.cos_bucket[0].id : null
  bucket_region        = var.create_cos_bucket ? ibm_cos_bucket.cos_bucket[0].region_location : null
  bucket_name          = var.create_cos_bucket ? ibm_cos_bucket.cos_bucket[0].bucket_name : null
  bucket_storage_class = var.create_cos_bucket ? ibm_cos_bucket.cos_bucket[0].storage_class : null
  s3_endpoint_public   = var.create_cos_bucket ? ibm_cos_bucket.cos_bucket[0].s3_endpoint_public : null
  s3_endpoint_private  = var.create_cos_bucket ? ibm_cos_bucket.cos_bucket[0].s3_endpoint_private : null
  s3_endpoint_direct   = var.create_cos_bucket ? ibm_cos_bucket.cos_bucket[0].s3_endpoint_direct : null
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
# Bucket backup policies
##############################################################################

# Gather the details needed to create the IAM s2s auth policies required for the Vault Backup policies
locals {
  backup_vault_auth = [
    for policy in var.backup_policies : {
      "vault_account_id" : split("/", coalescelist(split(":", policy.target_backup_vault_crn))[6])[1]
      "vault_cos_guid" : coalescelist(split(":", policy.target_backup_vault_crn))[7]
      "vault_name" : coalescelist(split(":", policy.target_backup_vault_crn))[9]
    }
  ]
}

# Create an IAM authorization policy granting sync permissions from the source to the target bucket for each vault specified
resource "ibm_iam_authorization_policy" "vault_policy" {
  count = length(local.backup_vault_auth)
  roles = [
    "Backup Manager", "Writer"
  ]
  subject_attributes {
    name  = "accountId"
    value = local.cos_account_id
  }
  subject_attributes {
    name  = "serviceName"
    value = "cloud-object-storage"
  }
  subject_attributes {
    name  = "serviceInstance"
    value = local.cos_instance_guid
  }
  subject_attributes {
    name  = "resource"
    value = local.bucket_name
  }
  subject_attributes {
    name  = "resourceType"
    value = "bucket"
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.backup_vault_auth[count.index]["vault_account_id"]
  }
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "cloud-object-storage"
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.backup_vault_auth[count.index]["vault_cos_guid"]
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.backup_vault_auth[count.index]["vault_name"]
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "backup-vault"
  }
}

# wait for auth policy to be fully synced on the backend before creating backup policy
resource "time_sleep" "wait_for_vault_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.vault_policy]
  count      = length(local.backup_vault_auth) > 0 ? 1 : 0
  # workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
  create_duration = "30s"
  # workaround for https://github.com/terraform-ibm-modules/terraform-ibm-cos/issues/672
  destroy_duration = "30s"
}

# Create policies
resource "ibm_cos_backup_policy" "policy" {
  depends_on = [time_sleep.wait_for_vault_authorization_policy]
  for_each   = var.create_cos_bucket ? { for policy in var.backup_policies : policy.policy_name => policy } : {}

  bucket_crn                = local.bucket_crn
  policy_name               = each.value.policy_name
  target_backup_vault_crn   = each.value.target_backup_vault_crn
  backup_type               = "continuous" # Currently only continuous is supported
  initial_delete_after_days = each.value.initial_delete_after_days
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
  version          = "1.35.16"
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
  version          = "1.35.16"
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
