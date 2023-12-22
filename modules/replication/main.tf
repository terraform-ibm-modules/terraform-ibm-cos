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
  origin_bucket_crn                = module.cos_origin_bucket.bucket_crn
  origin_bucket_instance_guid      = module.cos_origin_bucket.cos_instance_guid
  origin_bucket_location           = var.origin_bucket_config.region_location
  origin_bucket_name               = var.origin_bucket_config.bucket_name
  destination_bucket_crn           = module.cos_destination_bucket.bucket_crn
  destination_bucket_instance_guid = module.cos_destination_bucket.cos_instance_guid
  destination_bucket_name          = var.destination_bucket_config.bucket_name
  replication_rule                 = each.value
  skip_iam_authorization_policy    = var.skip_iam_authorization_policy
}

module "reverse_rules" {
  source = "../replication_rule/"
  for_each = {
    for index, rule in var.reverse_replication_rules :
    rule.rule_id => rule
  }
  origin_bucket_crn                = module.cos_destination_bucket.bucket_crn
  origin_bucket_instance_guid      = module.cos_destination_bucket.cos_instance_guid
  origin_bucket_location           = var.destination_bucket_config.region_location
  origin_bucket_name               = var.destination_bucket_config.bucket_name
  destination_bucket_crn           = module.cos_origin_bucket.bucket_crn
  destination_bucket_instance_guid = module.cos_origin_bucket.cos_instance_guid
  destination_bucket_name          = var.origin_bucket_config.bucket_name
  replication_rule                 = each.value
  skip_iam_authorization_policy    = var.skip_iam_authorization_policy
}

# Might want to own iam policy at this level
#
# Create one if length var.replication_rules is more than 0
# Create the other if legnth var.reverse_replication_rules is more than 0
