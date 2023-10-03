locals {
  # tflint-ignore: terraform_unused_declarations
  validate_different_regions = var.primary_region == var.secondary_region ? tobool("primary and secondary bucket regions must not match") : true
  # tflint-ignore: terraform_unused_declarations
  validate_at_set = var.create_cos_bucket && var.activity_tracker_crn == null ? tobool("when var.create_cos_bucket is true, var.activity_tracker_crn must be provided") : true
  # tflint-ignore: terraform_unused_declarations
  validate_sysdig_set = var.create_cos_bucket && var.sysdig_crn == null ? tobool("when var.create_cos_bucket is true, var.sysdig_crn must be provided") : true
  # tflint-ignore: terraform_unused_declarations
  validate_primary_hpcs_instance_guid = var.create_cos_bucket && var.primary_existing_hpcs_instance_guid == null ? tobool("when var.create_cos_bucket is true, var.primary_existing_hpcs_instance_guid must be provided") : true
  # tflint-ignore: terraform_unused_declarations
  validate_primary_hpcs_key_crn = var.create_cos_bucket && var.primary_hpcs_key_crn == null ? tobool("when var.create_cos_bucket is true, var.primary_hpcs_key_crn must be provided") : true
  # tflint-ignore: terraform_unused_declarations
  validate_secondary_hpcs_instance_guid = var.create_cos_bucket && var.secondary_existing_hpcs_instance_guid == null ? tobool("when var.create_cos_bucket is true, var.secondary_existing_hpcs_instance_guid must be provided") : true
  # tflint-ignore: terraform_unused_declarations
  validate_secondary_hpcs_key_crn = var.create_cos_bucket && var.secondary_hpcs_key_crn == null ? tobool("when var.create_cos_bucket is true, var.secondary_hpcs_key_crn must be provided") : true
  # tflint-ignore: terraform_unused_declarations
  validate_hpcs_instance_guids_different = var.create_cos_bucket && var.primary_existing_hpcs_instance_guid == var.secondary_existing_hpcs_instance_guid ? tobool("when var.create_cos_bucket is true, var.primary_existing_hpcs_instance_guid and var.secondary_existing_hpcs_instance_guid must be different") : true
  # tflint-ignore: terraform_unused_declarations
  validate_secondary_hpcs_key_crns_different = var.create_cos_bucket && var.primary_hpcs_key_crn == var.secondary_hpcs_key_crn ? tobool("when var.create_cos_bucket is true, var.primary_hpcs_key_crn and var.secondary_hpcs_key_crn must be different") : true

}

module "cos_instance" {
  source                        = "../../"
  resource_group_id             = var.resource_group_id
  create_cos_instance           = var.create_cos_instance
  existing_cos_instance_id      = var.existing_cos_instance_id
  create_cos_bucket             = false
  skip_iam_authorization_policy = true
  cos_instance_name             = var.cos_instance_name
  create_hmac_key               = var.create_hmac_key
  hmac_key_name                 = var.hmac_key_name
  hmac_key_role                 = var.hmac_key_role
  cos_plan                      = var.cos_plan
  cos_tags                      = var.cos_tags
  sysdig_crn                    = var.sysdig_crn
  activity_tracker_crn          = var.activity_tracker_crn
  access_tags                   = var.access_tags
}

module "buckets" {
  source = "../../modules/buckets"
  bucket_configs = [
    {
      access_tags          = var.access_tags
      bucket_name          = var.primary_bucket_name
      kms_guid             = var.primary_existing_hpcs_instance_guid
      kms_key_crn          = var.primary_hpcs_key_crn
      storage_class        = var.bucket_storage_class
      region_location      = var.primary_region
      resource_group_id    = var.resource_group_id
      resource_instance_id = module.cos_instance.cos_instance_id
      activity_tracking = {
        activity_tracker_crn = var.activity_tracker_crn
      }
      archive_rule = {
        enable = true
        days   = var.archive_days
        type   = var.archive_type
      }
      metrics_monitoring = {
        metrics_monitoring_crn = var.sysdig_crn
      }
      object_versioning = {
        enable = true
      }
    },
    {
      access_tags          = var.access_tags
      bucket_name          = var.secondary_bucket_name
      kms_guid             = var.secondary_existing_hpcs_instance_guid
      kms_key_crn          = var.secondary_hpcs_key_crn
      storage_class        = var.bucket_storage_class
      region_location      = var.secondary_region
      resource_group_id    = var.resource_group_id
      resource_instance_id = module.cos_instance.cos_instance_id
      activity_tracking = {
        activity_tracker_crn = var.activity_tracker_crn
      }
      archive_rule = {
        enable = true
        days   = var.archive_days
        type   = var.archive_type
      }
      metrics_monitoring = {
        metrics_monitoring_crn = var.sysdig_crn
      }
      object_versioning = {
        enable = true
      }
    }
  ]
}

### Configure replication rule

resource "ibm_cos_bucket_replication_rule" "cos_replication_rule" {
  depends_on = [
    ibm_iam_authorization_policy.policy
  ]
  bucket_crn      = module.buckets.buckets[var.primary_bucket_name].bucket_crn
  bucket_location = var.primary_region
  replication_rule {
    rule_id                         = "replicate-everything"
    enable                          = true
    priority                        = 50
    deletemarker_replication_status = false
    destination_bucket_crn          = module.buckets.buckets[var.secondary_bucket_name].bucket_crn
  }
}

### Configure IAM authorization policy

# Data source to retrieve account ID
data "ibm_iam_account_settings" "iam_account_settings" {
}

# TODO: how do we support buckets in different accounts?
resource "ibm_iam_authorization_policy" "policy" {
  roles = [
    "Writer",
  ]
  subject_attributes {
    name  = "accountId"
    value = data.ibm_iam_account_settings.iam_account_settings.account_id
  }
  subject_attributes {
    name  = "serviceName"
    value = "cloud-object-storage"
  }
  subject_attributes {
    name  = "serviceInstance"
    value = module.cos_instance.cos_instance_guid
  }
  subject_attributes {
    name  = "resource"
    value = var.primary_bucket_name
  }
  subject_attributes {
    name  = "resourceType"
    value = "bucket"
  }
  resource_attributes {
    name  = "accountId"
    value = data.ibm_iam_account_settings.iam_account_settings.account_id
  }
  resource_attributes {
    name  = "serviceName"
    value = "cloud-object-storage"
  }
  resource_attributes {
    name  = "serviceInstance"
    value = module.cos_instance.cos_instance_guid
  }
  resource_attributes {
    name  = "resource"
    value = var.secondary_bucket_name
  }
  resource_attributes {
    name  = "resourceType"
    value = "bucket"
  }
}

locals {

  access_tags = [
    for tag in var.access_tags :
    {
      name     = split(":", tag)[0] # Extract tag_name
      value    = split(":", tag)[1] # Extract tag_value
      operator = "stringEquals"
    }
  ]
  bucket_rule_resources = {
    for bucket in module.buckets.buckets : bucket.bucket_name => [
      {
        attributes = [
          {
            name     = "accountId"
            value    = data.ibm_iam_account_settings.iam_account_settings.account_id
            operator = "stringEquals"
          },
          {
            name     = "serviceInstance"
            value    = coalesce(bucket.bucket_crn, "test")
            operator = "stringEquals"
          },
          {
            name     = "serviceName"
            value    = "cloud-object-storage"
            operator = "stringEquals"
          }
        ],
        tags = local.access_tags == null ? [] : local.access_tags
      }
    ]
  }

  # append the bucket name onto the description
  bucket_rule_descriptions = {
    for bucket in module.buckets.buckets : bucket.bucket_name => "${var.bucket_cbr_rule.description} for bucket ${bucket.bucket_name}"
  }

}

# Create CBR Rules Last
module "bucket_cbr_rules" {
  depends_on       = [ibm_cos_bucket_replication_rule.cos_replication_rule]
  for_each         = { for bucket in module.buckets.buckets : bucket.bucket_name => bucket }
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.9.0"
  rule_description = local.bucket_rule_descriptions[each.key]
  enforcement_mode = var.bucket_cbr_rule.enforcement_mode
  rule_contexts    = var.bucket_cbr_rule.rule_contexts
  resources        = local.bucket_rule_resources[each.key]
  operations = var.bucket_cbr_rule.operations == null ? [{
    api_types = [
      {
        api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }
    ]
  }] : var.bucket_cbr_rule.operations
}

module "instance_cbr_rule" {
  depends_on       = [module.bucket_cbr_rules]
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.9.0"
  rule_description = var.instance_cbr_rule.description
  enforcement_mode = var.instance_cbr_rule.enforcement_mode
  rule_contexts    = var.instance_cbr_rule.rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.instance_cbr_rule.account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = module.cos_instance.cos_instance_guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "cloud-object-storage"
        operator = "stringEquals"
      }
    ],
    tags = local.access_tags == null ? [] : local.access_tags
  }]
  operations = var.instance_cbr_rule.operations == null ? [{
    api_types = [
      {
        api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }
    ]
  }] : var.instance_cbr_rule.operations
}

locals {
  bucket_rule_ids = [
    for bucket_name, bucket_rule in module.bucket_cbr_rules :
    bucket_rule.rule_id
  ]

  all_rule_ids = concat(local.bucket_rule_ids, [module.instance_cbr_rule.rule_id])
}
