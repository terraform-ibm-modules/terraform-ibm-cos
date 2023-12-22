##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

locals {
  origin_bucket_config = {
    bucket_name          = "${var.prefix}-bucket-origin"
    region_location      = "us-south"
    resource_group_id    = module.resource_group.resource_group_id
    resource_instance_id = module.cos.cos_instance_id
  }
  source_replication_rules = [
    {
      rule_id                         = "replicate-everything"
      enable                          = true
      priority                        = 50
      deletemarker_replication_status = false
    }
  ]
  target_bucket_config = {
    bucket_name          = "${var.prefix}-bucket-destination"
    region_location      = "us-east"
    resource_group_id    = module.resource_group.resource_group_id
    resource_instance_id = module.cos.cos_instance_id
  }
}

##############################################################################
# Create COS source bucket
##############################################################################

module "cos" {
  source                 = "../../"
  resource_group_id      = module.resource_group.resource_group_id
  region                 = var.region
  cos_instance_name      = "${var.prefix}-cos"
  cos_tags               = var.resource_tags
  create_cos_bucket      = false
  retention_enabled      = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled = false
}

##############################################################################
# Create COS source bucket
##############################################################################

module "replica_set" {
  source                    = "../../modules/replication"
  origin_bucket_config      = local.origin_bucket_config
  replication_rules         = local.source_replication_rules
  destination_bucket_config = local.target_bucket_config
}
