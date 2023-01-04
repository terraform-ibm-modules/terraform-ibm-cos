##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create Key Protect resources outside of terraform-ibm-cos module
##############################################################################

locals {
  key_ring_name = "cos-key-ring"
  key_name      = "cos-key"
}

module "key_protect_all_inclusive" {
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v3.0.0"
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
# Create COS instance outside of terraform-ibm-cos module
##############################################################################

resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.prefix}-cos"
  resource_group_id = module.resource_group.resource_group_id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  tags              = var.resource_tags
}

# Create IAM Access Policy to allow Key protect to access COS instance
resource "ibm_iam_authorization_policy" "policy" {
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = ibm_resource_instance.cos_instance.id
  target_service_name         = "kms"
  target_resource_instance_id = module.key_protect_all_inclusive.key_protect_guid
  roles                       = ["Reader"]
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
  source                      = "../../"
  existing_cos_instance_id    = ibm_resource_instance.cos_instance.id
  create_key_protect_instance = false
  create_cos_instance         = false
  create_key_protect_key      = false
  key_protect_key_crn         = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].crn
  bucket_name                 = "${var.prefix}-bucket"
  resource_group_id           = module.resource_group.resource_group_id
  region                      = var.region
  encryption_enabled          = true
  retention_enabled           = false
}
