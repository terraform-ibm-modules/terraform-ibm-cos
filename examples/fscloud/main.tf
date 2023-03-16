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
# VPC
##############################################################################
resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

##############################################################################
# Observability Instances (Sysdig + AT)
##############################################################################

locals {
  existing_at = var.existing_at_instance_crn != null ? true : false
  at_crn      = var.existing_at_instance_crn == null ? module.observability_instances.activity_tracker_crn : var.existing_at_instance_crn
}

# Create Sysdig and Activity Tracker instance
module "observability_instances" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances?ref=v2.1.0"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  region                         = var.region
  resource_group_id              = module.resource_group.resource_group_id
  sysdig_instance_name           = "${var.prefix}-sysdig"
  sysdig_plan                    = "graduated-tier"
  enable_platform_logs           = false
  enable_platform_metrics        = false
  logdna_provision               = false
  activity_tracker_instance_name = "${var.prefix}-at"
  activity_tracker_tags          = var.resource_tags
  activity_tracker_plan          = "7-day"
  activity_tracker_provision     = !local.existing_at
  logdna_tags                    = var.resource_tags
  sysdig_tags                    = var.resource_tags
}

##############################################################################
# Create Key Protect resources for Demo purposes for FSCloud use Hyper Protect Crypto Service
##############################################################################

locals {
  key_ring_name = "cos-key-ring"
  key_name      = "cos-key"
}

module "key_protect_all_inclusive_primary" {
  count                     = var.primary_existing_hpcs_instance_guid != null ? 0 : 1
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v4.0.0"
  key_protect_instance_name = "${var.prefix}-primary-kp"
  resource_group_id         = module.resource_group.resource_group_id
  enable_metrics            = false
  region                    = var.primary_region
  key_map = {
    (local.key_ring_name) = [local.key_name]
  }
  resource_tags = var.resource_tags
}

module "key_protect_all_inclusive_secondary" {
  count                     = var.secondary_existing_hpcs_instance_guid != null ? 0 : 1
  source                    = "git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git?ref=v4.0.0"
  key_protect_instance_name = "${var.prefix}-secondary-kp"
  resource_group_id         = module.resource_group.resource_group_id
  enable_metrics            = false
  region                    = var.secondary_region
  key_map = {
    (local.key_ring_name) = [local.key_name]
  }
  resource_tags = var.resource_tags
}


locals {
  primary_kms_guid      = var.primary_existing_hpcs_instance_guid != null ? var.primary_existing_hpcs_instance_guid : module.key_protect_all_inclusive_primary[0].key_protect_guid
  primary_kms_key_crn   = var.primary_existing_hpcs_instance_guid != null ? var.primary_hpcs_key_crn : module.key_protect_all_inclusive_primary[0].keys["${local.key_ring_name}.${local.key_name}"].crn
  secondary_kms_guid    = var.secondary_existing_hpcs_instance_guid != null ? var.secondary_existing_hpcs_instance_guid : module.key_protect_all_inclusive_secondary[0].key_protect_guid
  secondary_kms_key_crn = var.secondary_existing_hpcs_instance_guid != null ? var.secondary_hpcs_key_crn : module.key_protect_all_inclusive_secondary[0].keys["${local.key_ring_name}.${local.key_name}"].crn
}
##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone
##############################################################################
module "cbr_zone" {
  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-zone-module?ref=v1.1.4"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone containing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}

module "cos_fscloud" {
  source                                = "../../profiles/fscloud"
  resource_group_id                     = module.resource_group.resource_group_id
  cos_instance_name                     = "${var.prefix}-cos"
  cos_tags                              = var.resource_tags
  bucket_name                           = "${var.prefix}-bucket-1"
  primary_region                        = var.primary_region
  primary_existing_hpcs_instance_guid   = local.primary_kms_guid
  primary_hpcs_key_crn                  = local.primary_kms_key_crn
  secondary_existing_hpcs_instance_guid = local.secondary_kms_guid
  secondary_region                      = var.secondary_region
  secondary_hpcs_key_crn                = local.secondary_kms_key_crn
  sysdig_crn                            = module.observability_instances.sysdig_crn
  activity_tracker_crn                  = local.at_crn
  bucket_cbr_rules = [
    {
      description      = "sample rule for bucket 1"
      enforcement_mode = "report"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
    }
  ]
  instance_cbr_rules = [
    {
      description      = "sample rule for the instance"
      enforcement_mode = "report"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      # IAM tags on the rule resources should match to the instance level IAM tags
      tags = [
        {
          name  = "env"
          value = "test"
        }
      ]
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
    }
  ]
}

# IAM tags for the instance to match to the CBR rule tags.
# Tags are expected to exist in advance
resource "ibm_resource_tag" "instance_tags" {
  resource_id = module.cos_fscloud.cos_instance_id
  tag_type    = "access" # MUST be type access for CBR rule to work
  tags        = ["env:test"]
}
