##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Cloud Object Storage instance and a bucket
##############################################################################

module "cos" {
  source                 = "../../"
  resource_group_id      = module.resource_group.resource_group_id
  region                 = var.region
  cos_instance_name      = "${var.prefix}-cos"
  cos_tags               = var.resource_tags
  bucket_name            = "${var.prefix}-bucket"
  retention_enabled      = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled = false
}

##############################################################################
# Create Cloud Object Storage bucket using buckets submodule
##############################################################################

module "buckets" {
  source = "../../modules/buckets"
  bucket_configs = [
    {
      bucket_name            = "${var.prefix}-bucket-module-ff"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
      object_versioning = {
        enable = false
      }
      object_lock_duration_days  = 1
      object_lock_duration_years = 0
      object_locking_enabled     = false
    },
    {
      bucket_name            = "${var.prefix}-bucket-module-tf"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
      object_versioning = {
        enable = true
      }
      object_lock_duration_days  = 1
      object_lock_duration_years = 0
      object_locking_enabled     = false
    },
    {
      bucket_name            = "${var.prefix}-bucket-module-tt"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
      object_versioning = {
        enable = true
      }
      object_lock_duration_days  = 1
      object_lock_duration_years = 0
      object_locking_enabled     = true
    },
    {
      bucket_name            = "${var.prefix}-bucket-module-ft"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
      object_versioning = {
        enable = false
      }
      object_lock_duration_days  = 1
      object_lock_duration_years = 0
      object_locking_enabled     = false
    }
  ]
}
