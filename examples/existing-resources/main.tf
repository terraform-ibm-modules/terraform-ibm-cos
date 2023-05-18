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
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v4.1.0"
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
# Create serviceID to use for resource key hmac
##############################################################################

resource "ibm_iam_service_id" "resource_key_existing_serviceid" {
  name        = "${var.prefix}-reskey-serviceid"
  description = "ServiceID for ${var.prefix} env to use for resource key credentials"
}

##############################################################################
# Create COS instance only
##############################################################################

module "cos_instance" {
  source                              = "../../"
  cos_instance_name                   = "${var.prefix}-cos"
  create_cos_bucket                   = false
  resource_group_id                   = module.resource_group.resource_group_id
  existing_kms_instance_guid          = module.key_protect_all_inclusive.key_protect_guid
  region                              = var.region
  cross_region_location               = null
  activity_tracker_crn                = null
  access_tags                         = var.access_tags
  resource_key_existing_serviceid_crn = ibm_iam_service_id.resource_key_existing_serviceid.crn
  skip_iam_authorization_policy       = true
}

# Create IAM Authorization Policy to allow COS to access key protect for the encryption key
resource "ibm_iam_authorization_policy" "policy" {
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = module.cos_instance.cos_instance_guid
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

module "buckets" {
  source = "../../modules/buckets"
  bucket_configs = [
    {
      bucket_name          = "${var.prefix}-encrypted-bucket"
      kms_key_crn          = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].crn
      region_location      = var.region
      resource_group_id    = module.resource_group.resource_group_id
      resource_instance_id = module.cos_instance.cos_instance_id
    },
    {
      bucket_name            = "${var.prefix}-versioned-bucket"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_group_id      = module.resource_group.resource_group_id
      resource_instance_id   = module.cos_instance.cos_instance_id
      object_versioning = {
        enable = true
      }
    },
    {
      bucket_name            = "${var.prefix}-archive-bucket"
      kms_encryption_enabled = false
      region_location        = var.region
      resource_group_id      = module.resource_group.resource_group_id
      resource_instance_id   = module.cos_instance.cos_instance_id
      archive_rule = {
        days   = 90
        enable = true
        type   = "Accelerated"
      }
      expire_rule = {
        days   = 90
        enable = true
      }
    }
  ]
}
