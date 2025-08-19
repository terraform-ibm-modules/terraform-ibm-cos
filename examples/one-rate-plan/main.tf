##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.3.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create COS instance with One Rate Plan.
# Create COS bucket with One Rate Active Bucket Storage Class
##############################################################################

module "cos_bucket" {
  source                 = "../../"
  resource_group_id      = module.resource_group.resource_group_id
  region                 = var.region
  cross_region_location  = null
  cos_instance_name      = "${var.prefix}-cos"
  cos_tags               = var.resource_tags
  bucket_name            = "${var.prefix}-bucket-one-rate"
  retention_enabled      = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled = false
  cos_plan               = "cos-one-rate-plan"
  bucket_storage_class   = "onerate_active"
  access_tags            = var.access_tags
}
