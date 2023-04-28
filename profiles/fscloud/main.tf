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
  source                   = "../../"
  resource_group_id        = var.resource_group_id
  create_cos_instance      = var.create_cos_instance
  existing_cos_instance_id = var.existing_cos_instance_id
  create_cos_bucket        = false
  #  Since two policies are needed we disable here and define them manually below
  skip_iam_authorization_policy = true
  cos_instance_name             = var.cos_instance_name
  create_hmac_key               = var.create_hmac_key
  hmac_key_name                 = var.hmac_key_name
  hmac_key_role                 = var.hmac_key_role
  cos_plan                      = var.cos_plan
  cos_tags                      = var.cos_tags
  sysdig_crn                    = var.sysdig_crn
  activity_tracker_crn          = var.activity_tracker_crn
  instance_cbr_rules            = var.instance_cbr_rules
}

# Create IAM Authorization Policies to allow COS to access kms for the encryption key
resource "ibm_iam_authorization_policy" "primary_kms_policy" {
  count                       = var.skip_iam_authorization_policy ? 0 : 1
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = module.cos_instance.cos_instance_guid
  target_service_name         = "hs-crypto"
  target_resource_instance_id = var.primary_existing_hpcs_instance_guid
  roles                       = ["Reader"]
}

resource "ibm_iam_authorization_policy" "secondary_kms_policy" {
  count                       = var.skip_iam_authorization_policy ? 0 : 1
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = module.cos_instance.cos_instance_guid
  target_service_name         = "hs-crypto"
  target_resource_instance_id = var.secondary_existing_hpcs_instance_guid
  roles                       = ["Reader"]
}

module "cos_primary_bucket" {
  depends_on                 = [ibm_iam_authorization_policy.primary_kms_policy]
  source                     = "../../"
  resource_group_id          = var.resource_group_id
  region                     = var.primary_region
  create_cos_instance        = false
  existing_cos_instance_id   = module.cos_instance.cos_instance_id
  create_cos_bucket          = var.create_cos_bucket
  bucket_name                = var.primary_bucket_name
  bucket_storage_class       = var.bucket_storage_class
  retention_enabled          = false
  archive_days               = var.archive_days
  archive_type               = var.archive_type
  expire_days                = null
  object_versioning_enabled  = "true"
  existing_kms_instance_guid = var.primary_existing_hpcs_instance_guid
  kms_key_crn                = var.primary_hpcs_key_crn
  kms_encryption_enabled     = "true"
  activity_tracker_crn       = var.activity_tracker_crn
  sysdig_crn                 = var.sysdig_crn
  bucket_cbr_rules           = var.bucket_cbr_rules
}

module "cos_secondary_bucket" {
  depends_on                 = [ibm_iam_authorization_policy.secondary_kms_policy]
  source                     = "../../"
  resource_group_id          = var.resource_group_id
  region                     = var.secondary_region
  create_cos_instance        = false
  existing_cos_instance_id   = module.cos_instance.cos_instance_id
  create_cos_bucket          = var.create_cos_bucket
  bucket_name                = var.secondary_bucket_name
  bucket_storage_class       = var.bucket_storage_class
  retention_enabled          = false
  archive_days               = var.archive_days
  archive_type               = var.archive_type
  expire_days                = null
  object_versioning_enabled  = "true"
  existing_kms_instance_guid = var.secondary_existing_hpcs_instance_guid
  kms_key_crn                = var.secondary_hpcs_key_crn
  kms_encryption_enabled     = "true"
  activity_tracker_crn       = var.activity_tracker_crn
  sysdig_crn                 = var.sysdig_crn
  bucket_cbr_rules           = var.bucket_cbr_rules
}

### Configure replication rule

resource "ibm_cos_bucket_replication_rule" "cos_replication_rule" {
  depends_on = [
    ibm_iam_authorization_policy.policy
  ]
  bucket_crn      = module.cos_primary_bucket.bucket_crn[0]
  bucket_location = var.primary_region
  replication_rule {
    rule_id                         = "replicate-everything"
    enable                          = true
    priority                        = 50
    deletemarker_replication_status = false
    destination_bucket_crn          = module.cos_secondary_bucket.bucket_crn[0]
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
    value = module.cos_primary_bucket.bucket_name[0]
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
    value = module.cos_secondary_bucket.cos_instance_guid
  }
  resource_attributes {
    name  = "resource"
    value = module.cos_secondary_bucket.bucket_name[0]
  }
  resource_attributes {
    name  = "resourceType"
    value = "bucket"
  }
}
