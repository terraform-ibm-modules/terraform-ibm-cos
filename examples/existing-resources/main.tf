##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Key Protect resources
##############################################################################

locals {
  key_ring_name = "cos-key-ring"
  key_name      = "cos-key"
}

module "key_protect_all_inclusive" {
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v3.1.2"
  key_protect_instance_name = "${var.prefix}-kp"
  resource_group_id         = module.resource_group.resource_group_id
  enable_metrics            = false
  region                    = var.region
  key_map = {
    (local.key_ring_name) = [local.key_name]
  }
  resource_tags = var.resource_tags
}

##############################################################################
# Create COS instance only
##############################################################################

module "cos_instance" {
  source                             = "../../"
  cos_instance_name                  = "${var.prefix}-cos"
  create_cos_bucket                  = false
  resource_group_id                  = module.resource_group.resource_group_id
  existing_key_protect_instance_guid = module.key_protect_all_inclusive.key_protect_guid
  region                             = var.region
  cross_region_location              = null
  activity_tracker_crn               = null
}

##############################################################################
# Create COS bucket with:
# - Encryption
# Create COS bucket without:
# - Retention
# - Monitoring
# - Activity Tracking
##############################################################################

module "cos" {
  source                   = "../../"
  create_cos_instance      = false
  existing_cos_instance_id = module.cos_instance.cos_instance_id
  key_protect_key_crn      = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].crn
  bucket_name              = "${var.prefix}-bucket"
  resource_group_id        = module.resource_group.resource_group_id
  region                   = var.region
  cross_region_location    = null
  encryption_enabled       = true
  # disable retention for test environments - enable for stage/prod
  retention_enabled    = false
  activity_tracker_crn = null
}
