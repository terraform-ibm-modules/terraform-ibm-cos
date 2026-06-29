##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create COS source bucket
##############################################################################

module "cos_source_bucket" {
  source                             = "../../"
  bucket_name                        = "${var.prefix}-bucket-source"
  resource_group_id                  = module.resource_group.resource_group_id
  region                             = var.region
  cos_instance_name                  = "${var.prefix}-source-cos"
  resource_tags                      = var.resource_tags
  access_tags                        = var.access_tags
  object_versioning_enabled          = true
  kms_encryption_enabled             = false
  expire_days                        = 365
  archive_days                       = 90
  noncurrent_version_expiration_days = 30
  abort_multipart_days               = 3
}

##############################################################################
# Create COS target bucket
##############################################################################

module "cos_target_bucket" {
  source                             = "../../"
  bucket_name                        = "${var.prefix}-bucket-target"
  resource_group_id                  = module.resource_group.resource_group_id
  region                             = var.region
  cos_instance_name                  = "${var.prefix}-target-cos"
  resource_tags                      = var.resource_tags
  access_tags                        = var.access_tags
  object_versioning_enabled          = true
  kms_encryption_enabled             = false
  expire_days                        = 365
  archive_days                       = 90
  noncurrent_version_expiration_days = 30
  abort_multipart_days               = 3
}

##############################################################################
# Configure replication using the replication module
##############################################################################

module "cos_replication" {
  source = "../../modules/replication"

  # Source bucket configuration
  source_bucket_crn    = module.cos_source_bucket.bucket_crn
  source_bucket_region = var.region

  replication_rules = [
    {
      rule_id                         = "replicate-everything"
      enable                          = true
      priority                        = 50
      prefix                          = null
      deletemarker_replication_status = false
      destination_bucket_crn          = module.cos_target_bucket.bucket_crn
    }
  ]
}
