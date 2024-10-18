##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create serviceID to use for resource key hmac
#
# NOTE: The module itself supports creating internally, but this example shows
# how to use an existing ones
##############################################################################
resource "ibm_iam_service_id" "resource_key_existing_serviceid" {
  name        = "${var.prefix}-reskey-serviceid"
  description = "ServiceID for ${var.prefix} env to use for resource key credentials"
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
# Create Key Protect resources
##############################################################################

locals {
  key_ring_name = "cos-key-ring"
  key_name      = "cos-key"
}

module "key_protect_all_inclusive" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "4.16.1"
  key_protect_instance_name = "${var.prefix}-kp"
  resource_group_id         = module.resource_group.resource_group_id
  enable_metrics            = false
  region                    = var.region
  keys = [
    {
      key_ring_name = (local.key_ring_name)
      keys = [
        {
          key_name = (local.key_name)
        }
      ]
    }
  ]
  resource_tags = var.resource_tags
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
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.28.0"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone containing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}

##############################################################################
# Create COS instance and COS bucket-1 with:
# - Encryption
##############################################################################

module "cos_bucket1" {
  source                              = "../../"
  resource_group_id                   = module.resource_group.resource_group_id
  region                              = var.region
  cross_region_location               = null
  cos_instance_name                   = "${var.prefix}-cos"
  cos_tags                            = var.resource_tags
  bucket_name                         = "${var.prefix}-bucket-1"
  access_tags                         = var.access_tags
  management_endpoint_type_for_bucket = var.management_endpoint_type_for_bucket
  existing_kms_instance_guid          = module.key_protect_all_inclusive.kms_guid
  kms_key_crn                         = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].crn
  retention_enabled                   = false # disable retention for test environments - enable for stage/prod
  resource_keys = [
    {
      name           = "${var.prefix}-writer-key"
      key_name       = ibm_iam_service_id.resource_key_existing_serviceid.iam_id
      role           = "Writer"
      service_id_crn = ibm_iam_service_id.resource_key_existing_serviceid.crn
    },
    {
      name = "${var.prefix}-reader-key"
    },
    {
      name = "${var.prefix}-manager-key"
      role = "Manager"
    },
    {
      name = "${var.prefix}-content-reader-key"
      role = "Content Reader"
    },
    {
      name = "${var.prefix}-object-reader-key"
      role = "Object Reader"
    },
    {
      name = "${var.prefix}-object-writer-key"
      role = "Object Writer"
    }
  ]
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

##############################################################################
# Create COS bucket-2 (in the COS instance created above) with:
# - Cross Region Location
# - Encryption
##############################################################################

module "cos_bucket2" {
  source                              = "../../"
  depends_on                          = [module.cos_bucket1] # Required since cos_bucket1 creates the IAM authorization policy
  bucket_name                         = "${var.prefix}-bucket-2"
  add_bucket_name_suffix              = true
  management_endpoint_type_for_bucket = var.management_endpoint_type_for_bucket
  region                              = null
  cross_region_location               = var.cross_region_location
  archive_days                        = null
  create_cos_instance                 = false
  existing_cos_instance_id            = module.cos_bucket1.cos_instance_id
  skip_iam_authorization_policy       = true  # Required since cos_bucket1 creates the IAM authorization policy
  retention_enabled                   = false # disable retention for test environments - enable for stage/prod
  kms_key_crn                         = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].crn
  bucket_cbr_rules = [
    {
      description      = "sample rule for bucket 2"
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
}

##############################################################################
# Create COS bucket-3 (in the COS instance created above) with:
# - Single Site Location
# - Hard Quota
# - Encryption
##############################################################################

module "cos_bucket3" {
  source                              = "../../"
  depends_on                          = [module.cos_bucket1] # Required since cos_bucket1 creates the IAM authorization policy
  bucket_name                         = "${var.prefix}-bucket-3"
  add_bucket_name_suffix              = true
  management_endpoint_type_for_bucket = var.management_endpoint_type_for_bucket
  region                              = null
  single_site_location                = var.single_site_location
  hard_quota                          = "1000000" #Sets a maximum amount of storage (in bytes) available for a bucket. If it is set to `null` then quota is disabled.
  archive_days                        = null
  create_cos_instance                 = false
  existing_cos_instance_id            = module.cos_bucket1.cos_instance_id
  kms_encryption_enabled              = false # disable encryption because single site location doesn't support it
  skip_iam_authorization_policy       = true  # Required since cos_bucket1 creates the IAM authorization policy
  retention_enabled                   = false # disable retention for test environments - enable for stage/prod
  bucket_cbr_rules = [
    {
      description      = "sample rule for bucket 3"
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
}
