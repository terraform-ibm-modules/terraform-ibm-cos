##############################################################################
# Create COS origin bucket
##############################################################################

module "cos_origin_bucket" {
  source              = "../../"
  bucket_name         = var.origin_bucket_config.bucket_name
  create_cos_instance = false
  resource_group_id   = var.origin_bucket_config.resource_group_id
  region              = var.origin_bucket_config.region_location
  # cos_instance_name         = var.origin_bucket_config.cos_instance_name
  # cos_tags                  = var.origin_bucket_config.resource_tags
  existing_cos_instance_id  = var.origin_bucket_config.resource_instance_id
  access_tags               = var.origin_bucket_config.access_tags
  object_versioning_enabled = true
  kms_encryption_enabled    = false
  retention_enabled         = false
  archive_days              = null
  expire_days               = null
}

##############################################################################
# Create COS destination bucket
##############################################################################

module "cos_destination_bucket" {
  source              = "../../"
  bucket_name         = var.destination_bucket_config.bucket_name
  create_cos_instance = false
  resource_group_id   = var.destination_bucket_config.resource_group_id
  region              = var.destination_bucket_config.region_location
  # cos_instance_name         = var.destination_bucket_config.cos_instance_name
  # cos_tags                  = var.destination_bucket_config.resource_tags
  existing_cos_instance_id  = var.origin_bucket_config.resource_instance_id
  access_tags               = var.destination_bucket_config.access_tags
  object_versioning_enabled = true
  kms_encryption_enabled    = false
  retention_enabled         = false
  archive_days              = null
  expire_days               = null
}

##############################################################################
# Configure replication rule
##############################################################################

module "origin_rules" {
  source = "../replication_rule/"
  for_each = {
    for index, rule in var.replication_rules :
    rule.rule_id => rule
  }
  origin_bucket_crn           = module.cos_origin_bucket.bucket_crn
  origin_bucket_instance_guid = module.cos_origin_bucket.cos_instance_guid
  origin_bucket_location      = var.origin_bucket_config.region_location
  destination_bucket_crn      = module.cos_destination_bucket.bucket_crn
  replication_rule            = each.value
}

module "reverse_rules" {
  source = "../replication_rule/"
  for_each = {
    for index, rule in var.reverse_replication_rules :
    rule.rule_id => rule
  }
  origin_bucket_crn           = module.cos_destination_bucket.bucket_crn
  origin_bucket_instance_guid = module.cos_destination_bucket.cos_instance_guid
  origin_bucket_location      = var.destination_bucket_config.region_location
  destination_bucket_crn      = module.cos_origin_bucket.bucket_crn
  replication_rule            = each.value
}

resource "ibm_cos_bucket_replication_rule" "cos_replication_rule" {
  depends_on = [
    ibm_iam_authorization_policy.policy
  ]
  bucket_crn      = module.cos_origin_bucket.bucket_crn
  bucket_location = var.origin_bucket_config.region_location
  replication_rule {
    rule_id                         = "replicate-everything"
    enable                          = true
    priority                        = 50
    deletemarker_replication_status = false
    destination_bucket_crn          = module.cos_destination_bucket.bucket_crn
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
    value = module.cos_origin_bucket.cos_instance_guid
  }
  subject_attributes {
    name  = "resource"
    value = module.cos_origin_bucket.bucket_name
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
    value = module.cos_destination_bucket.cos_instance_guid
  }
  resource_attributes {
    name  = "resource"
    value = module.cos_destination_bucket.bucket_name
  }
  resource_attributes {
    name  = "resourceType"
    value = "bucket"
  }
}
