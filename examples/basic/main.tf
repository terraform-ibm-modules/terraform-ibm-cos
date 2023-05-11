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
# Create COS
##############################################################################

module "cos_bucket" {
  source            = "../../"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  cos_instance_name = "${var.prefix}-cos"
  cos_tags          = var.resource_tags
  bucket_name       = "${var.prefix}-bucket"
  # disable retention for test environments - enable for stage/prod
  retention_enabled      = false
  kms_encryption_enabled = false
}
