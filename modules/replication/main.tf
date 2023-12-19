##############################################################################
# Create COS source bucket
##############################################################################

module "cos_source_bucket" {
  source                    = "../../"
  bucket_name               = var.source_bucket_config.bucket_name
  create_cos_instance       = false
  resource_group_id         = var.source_bucket_config.resource_group_id
  region                    = var.source_bucket_config.region_location
  # cos_instance_name         = var.source_bucket_config.cos_instance_name
  # cos_tags                  = var.source_bucket_config.resource_tags
  existing_cos_instance_id  = var.source_bucket_config.cos_instance_id
  access_tags               = var.source_bucket_config.access_tags
  object_versioning_enabled = true
  kms_encryption_enabled    = false
  retention_enabled         = false
  archive_days              = null
  expire_days               = null
}

##############################################################################
# Create COS target bucket
##############################################################################

module "cos_target_bucket" {
  source                    = "../../"
  bucket_name               = var.target_bucket_config.bucket_name
  create_cos_instance       = false
  resource_group_id         = var.target_bucket_config.resource_group_id
  region                    = var.target_bucket_config.region_location
  # cos_instance_name         = var.target_bucket_config.cos_instance_name
  # cos_tags                  = var.target_bucket_config.resource_tags
  existing_cos_instance_id  = var.source_bucket_config.cos_instance_id
  access_tags               = var.target_bucket_config.access_tags
  object_versioning_enabled = true
  kms_encryption_enabled    = false
  retention_enabled         = false
  archive_days              = null
  expire_days               = null
}

##############################################################################
# Configure replication rule
##############################################################################

resource "ibm_cos_bucket_replication_rule" "cos_replication_rule" {
  depends_on = [
    ibm_iam_authorization_policy.policy
  ]
  bucket_crn      = module.cos_source_bucket.bucket_crn
  bucket_location = var.source_bucket_config.region
  replication_rule {
    rule_id                         = "replicate-everything"
    enable                          = true
    priority                        = 50
    deletemarker_replication_status = false
    destination_bucket_crn          = module.cos_target_bucket.bucket_crn
  }
}

##############################################################################
# Retrieve account ID
##############################################################################
data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Configure IAM authorization policy
##############################################################################

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
    value = module.cos_source_bucket.cos_instance_guid
  }
  subject_attributes {
    name  = "resource"
    value = module.cos_source_bucket.bucket_name
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
    value = module.cos_target_bucket.cos_instance_guid
  }
  resource_attributes {
    name  = "resource"
    value = module.cos_target_bucket.bucket_name
  }
  resource_attributes {
    name  = "resourceType"
    value = "bucket"
  }
}
