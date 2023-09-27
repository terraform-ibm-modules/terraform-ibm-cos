##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.0.6"
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
  source  = "terraform-ibm-modules/observability-instances/ibm"
  version = "2.9.2"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  region                         = var.region
  resource_group_id              = module.resource_group.resource_group_id
  cloud_monitoring_instance_name = "${var.prefix}-sysdig"
  cloud_monitoring_plan          = "graduated-tier"
  enable_platform_logs           = false
  enable_platform_metrics        = false
  log_analysis_provision         = false
  activity_tracker_instance_name = "${var.prefix}-at"
  activity_tracker_tags          = var.resource_tags
  activity_tracker_plan          = "7-day"
  activity_tracker_provision     = !local.existing_at
  log_analysis_tags              = var.resource_tags
  cloud_monitoring_tags          = var.resource_tags
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
  version          = "1.12.1"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone containing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
}

module "cos_fscloud" {
  source                                = "../../modules/fscloud"
  resource_group_id                     = module.resource_group.resource_group_id
  cos_instance_name                     = "${var.prefix}-cos"
  cos_tags                              = var.resource_tags
  primary_bucket_name                   = "${var.prefix}-bucket-primary"
  primary_region                        = var.primary_region
  primary_existing_hpcs_instance_guid   = var.primary_existing_hpcs_instance_guid
  primary_hpcs_key_crn                  = var.primary_hpcs_key_crn
  secondary_bucket_name                 = "${var.prefix}-bucket-secondary"
  secondary_existing_hpcs_instance_guid = var.secondary_existing_hpcs_instance_guid
  secondary_region                      = var.secondary_region
  secondary_hpcs_key_crn                = var.secondary_hpcs_key_crn
  sysdig_crn                            = module.observability_instances.cloud_monitoring_crn
  activity_tracker_crn                  = local.at_crn
  access_tags                           = var.access_tags
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
