##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}


module "cos_bucket1" {
  source                              = "../../"
  resource_group_id                   = module.resource_group.resource_group_id
  region                              = var.region
  cross_region_location               = null
  cos_instance_name                   = "${var.prefix}-cos"
  cos_tags                            = var.resource_tags
  bucket_name                         = "${var.prefix}-bucket-1"
  management_endpoint_type_for_bucket = var.management_endpoint_type_for_bucket
  encryption_enabled                  = false
}

module "cos_bucket2" {
  source                              = "../../"
  resource_group_id                   = module.resource_group.resource_group_id
  region                              = null
  cross_region_location               = var.cross_region_location
  bucket_name                         = "${var.prefix}-bucket-2"
  management_endpoint_type_for_bucket = var.management_endpoint_type_for_bucket
  archive_days                        = null
  create_cos_instance                 = false
  existing_cos_instance_id            = module.cos_bucket1.cos_instance_id
  encryption_enabled                  = false
}
