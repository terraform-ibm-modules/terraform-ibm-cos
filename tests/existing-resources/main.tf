##############################################################################
# Permanent test resources for terraform-ibm-cos
#
# Creates a Key Protect Standard instance with the Cross-region resiliency
# pricing plan so it can be used to encrypt cross-regional COS buckets.
# (Cross-regional COS buckets cannot be encrypted with Key Protect Dedicated.)
##############################################################################

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.6.1"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect Standard (cross-region-resiliency plan)
##############################################################################

module "key_protect" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "5.6.10"
  key_protect_instance_name = "${var.prefix}-kp-standard-cross-region"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  resource_tags             = var.resource_tags
  key_protect_plan          = "cross-region-resiliency"
  keys = [
    {
      key_ring_name         = "${var.prefix}-cos-key-ring"
      existing_key_ring     = false
      force_delete_key_ring = true
      keys = [
        {
          key_name                 = "${var.prefix}-cos-root-key"
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}
